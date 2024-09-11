# Generates/retrieves a random password string or its hash for a
# passed identifier.
#
# * Password info is stored in files on the local file system at
#   `Puppet.settings[:vardir]/simp/environments/$environment/simp_autofiles/gen_passwd/`.
# * The minimum length password that this function will return is `8`
#   characters.
# * Terminates catalog compilation if the password storage directory
#   cannot be created/accessed by the Puppet user, the password cannot
#   be created in the allotted time, or files not owned by the Puppet
#   user are present in the password storage directory.
#
Puppet::Functions.create_function(:'simplib::passgen::legacy::passgen') do

  # @param identifier Unique `String` to identify the password usage.
  #
  # @param modifier_hash Options `Hash`. May include any
  #   of the following options:
  #   * `last` => `false`(*) or `true`
  #        * Return the last generated password
  #   * `length` => `Integer`
  #        * Length of the new password
  #   * `hash` => `false`(*), `true`, `md5`, `sha256` (true), `sha512`
  #        * Return a `Hash` of the password instead of the password itself
  #   * `complexity` => `0`(*), `1`, `2`
  #        * `0` => Use only Alphanumeric characters in your password (safest)
  #        * `1` => Add reasonably safe symbols
  #        * `2` => Printable ASCII
  #   * `user` => user for generated files/directories
  #        * Defaults to the user compiling the catalog.
  #        * Only useful when running `puppet apply` as the `root` user.
  #   * `group => Group for generated files/directories
  #        * Defaults to the group compiling the catalog.
  #        * Only useful when running `puppet apply` as the `root` user.
  #   **private options:**
  #   * `password` => contains the string representation of the password to hash (used for testing)
  #   * `salt` => contains the string literal salt to use (used for testing)
  #   * `complex_only` => use only the characters explicitly added by the complexity rules (used for testing)
  #
  # @return [String] Password or password hash specified. If no
  #   `modifier_hash` or an invalid `modifier_hash` is provided,
  #   it will return the currently stored/generated password.
  #
  dispatch :passgen do
    required_param 'String[1]', :identifier
    optional_param 'Hash',      :modifier_hash
  end

  def initialize(closure_scope, loader)
    super

    require 'puppet/util/symbolic_file_mode'
    # mixin Puppet::Util::SymbolicFileMode module for symbolic_mode_to_int()
    self.extend(Puppet::Util::SymbolicFileMode)
  end

  def passgen(identifier, modifier_hash={})
    require 'etc'
    require 'timeout'

    scope = closure_scope

    settings = {}
    settings['user'] = modifier_hash.key?('user') ? modifier_hash['user'] : Etc.getpwuid(Process.uid).name
    settings['group'] = modifier_hash.key?('group') ? modifier_hash['group'] : Etc.getgrgid(Process.gid).name
    settings['keydir'] = File.join(Puppet.settings[:vardir], 'simp',
      'environments', scope.lookupvar('::environment'),
      'simp_autofiles', 'gen_passwd'
    )
    settings['min_password_length'] = 8
    settings['default_password_length'] = 32
    settings['crypt_map'] = {
      'md5'     => '1',
      'sha256'  => '5',
      'sha512'  => '6'
    }

    base_options = {
      'return_current'      => false,
      'last'                => false,
      'length'              => settings['default_password_length'],
      'hash'                => false,
      'complexity'          => 0,
      'complex_only'        => false,
      'gen_timeout_seconds' => 30
    }

    options = build_options(base_options, modifier_hash, settings)

    unless File.directory?(settings['keydir'])
      begin
        FileUtils.mkdir_p(settings['keydir'],{:mode => 0750})
        # This chown is applicable as long as it is applied
        # by puppet, not puppetserver.
        FileUtils.chown(settings['user'],
         settings['group'], settings['keydir']
       )
      rescue SystemCallError => e
        err_msg = "simplib::passgen: Could not make directory" +
         " #{settings['keydir']}:  #{e.message}. Ensure that" +
         " #{File.dirname(settings['keydir'])} is writable by" +
         " '#{settings['user']}'"
        fail(err_msg)
      end
    end

    if options['last']
      passwd,salt = get_last_password(identifier, options, settings)
    else
      passwd,salt = get_current_password(identifier, options, settings)
    end

    lockdown_stored_password_perms(settings)

    # Return the hash, not the password
    if options['hash']
      return passwd.crypt("$#{settings['crypt_map'][options['hash']]}$#{salt}")
    else
      return passwd
    end
  rescue Timeout::Error => e
    fail("simplib::passgen timed out for #{identifier}!")
  end


  # Build a merged options hash and validate the options
  # raises ArgumentError if any option in the modifier_hash is invalid
  def build_options(base_options, modifier_hash, settings)
    options = base_options.dup
    if modifier_hash.empty?
      options['return_current'] = true
      return options
    end

    options.merge!(modifier_hash)

    if options['length'].to_s !~ /^\d+$/
      raise ArgumentError,
        "simplib::passgen: Error: Length '#{options['length']}' must be an integer!"
    else
      options['length'] = options['length'].to_i
      if options['length'] == 0
        options['length'] = settings['default_password_length']
      elsif options['length'] < settings['min_password_length']
        options['length'] = settings['min_password_length']
      end
    end

    if options['complexity'].to_s !~ /^\d+$/
      raise ArgumentError,
        "simplib::passgen: Error: Complexity '#{options['complexity']}' must be an integer!"
    else
      options['complexity'] = options['complexity'].to_i
    end

    if options['gen_timeout_seconds'].to_s !~ /^\d+$/
      raise ArgumentError,
        "simplib::passgen: Error: Password generation timeout '#{options['gen_timeout_seconds']}' must be an integer!"
    else
      options['gen_timeout_seconds'] = options['gen_timeout_seconds'].to_i
    end

    # Make sure a valid hash was passed if one was passed.
    if options['hash'] == true
      options['hash'] = 'sha256'
    end
    if options['hash'] and !settings['crypt_map'].keys.include?(options['hash'])
      raise ArgumentError,
       "simplib::passgen: Error: '#{options['hash']}' is not a valid hash."
    end
    return options
  end

  # Generate a password
  def gen_password(options)
    call_function('simplib::gen_random_password',
      options['length'],
      options['complexity'],
      options['complex_only'],
      options['gen_timeout_seconds']
    )
  end

  # Generate the salt to be used to encrypt a password
  def gen_salt(options)
    call_function('simplib::passgen::gen_salt',
      options['gen_timeout_seconds']
    )
  end

  # Retrieve or generate a current password
  #
  # If the password file doesn't exist, the file is empty, or the
  # length of the password that was read from the file is not equal
  # to the length of the expected password, then build a new password
  # file.
  #
  # If no options were passed, and the file exists, then just throw
  # back the value in the file.  If the file is empty, create the new
  # password anyway.
  #
  # Rotate if you're creating a new password.
  #
  # Add an associated 'salt' file for returning crypted passwords.
  def get_current_password(identifier, options, settings)
    # Open the file in append + read mode to prepare for what is to
    # come.
    tgt = File.new("#{settings['keydir']}/#{identifier}","a+")
    tgt_hash = File.new("#{tgt.path}.salt","a+")

    # These chowns are applicable as long as they are applied
    # by puppet, not puppetserver.
    FileUtils.chown(settings['user'],settings['group'],tgt.path)
    FileUtils.chown(settings['user'],settings['group'],tgt_hash.path)

    passwd = ''
    salt = ''

    # Create salt file if not there, no matter what, just in case we have an
    # upgraded system.
    if tgt_hash.stat.size.zero?
      if options.key?('salt')
        salt = options['salt']
      else
        salt = gen_salt(options)
      end
      tgt_hash.puts(salt)
      tgt_hash.rewind
    end

    if tgt.stat.size.zero?
      if options.key?('password')
        passwd = options['password']
      else
        passwd = gen_password(options)
      end
      tgt.puts(passwd)
    else
      passwd = tgt.gets.chomp
      salt = tgt_hash.gets.chomp

      if !options['return_current'] and passwd.length != options['length']
        tgt_last = File.new("#{tgt.path}.last","w+")
        tgt_last.puts(passwd)
        tgt_last.chmod(0640)
        tgt_last.flush
        tgt_last.close

        tgt_hash_last = File.new("#{tgt_hash.path}.last","w+")
        tgt_hash_last.puts(salt)
        tgt_hash_last.chmod(0640)
        tgt_hash_last.flush
        tgt_hash_last.close

        tgt.rewind
        tgt.truncate(0)
        passwd = gen_password(options)
        salt = gen_salt(options)

        tgt.puts(passwd)
        tgt_hash.puts(salt)
      end
    end

    tgt.chmod(0640)
    tgt.flush
    tgt.close

    [passwd, salt]
  end

  # Try to get the last password entry, if it exists.  If it doesn't
  # use the current entry, the 'password' in options, or a freshly-
  # generated password, in that order of precedence.  Also, warn the
  # user about manifest ordering problems, if we had to use the
  # 'password' in options or had to generate a password.
  def get_last_password(identifier, options, settings)
    toread = nil
    if File.exists?("#{settings['keydir']}/#{identifier}.last")
      toread = "#{settings['keydir']}/#{identifier}.last"
    else
      toread = "#{settings['keydir']}/#{identifier}"
    end

    passwd = ''
    salt = ''
    if File.exists?(toread)
      passwd = IO.readlines(toread)[0].to_s.chomp
      sf = "#{File.dirname(toread)}/#{File.basename(toread,'.last')}.salt.last"
      saltfile = File.open(sf,'a+',0640)
      if saltfile.stat.size.zero?
        if options.key?('salt')
          salt = options['salt']
        else
          salt = gen_salt(options)
        end
        saltfile.puts(salt)
        saltfile.close
      end
      salt = IO.readlines(sf)[0].to_s.chomp
    else
      warn_msg = "Could not find a primary or 'last' file for " +
        "#{identifier}, please ensure that you have included this" +
        " function in the proper order in your manifest!"
      Puppet.warning warn_msg
      if options.key?('password')
        passwd = options['password']
      else
        #FIXME?  Why doesn't this persist the password?
        passwd = gen_password(options)
      end
    end
    [passwd, salt]
  end

  # Ensure that the password space is readable and writable by the
  # Puppet user and no other users.
  # Fails if any file/directory not owned by the Puppet user is found.
  def lockdown_stored_password_perms(settings)
    unowned_files = []
    Find.find(settings['keydir']) do |file|
      file_stat = File.stat(file)

      # Do we own this file?
      begin
        file_owner = Etc.getpwuid(file_stat.uid).name

        unowned_files << file unless (file_owner == settings['user'])
      rescue ArgumentError => e
        debug("simplib::passgen: Error getting UID for #{file}: #{e}")

        unowned_files << file
      end

      # Ignore any file/directory that we don't own
      Find.prune if unowned_files.last == file

      FileUtils.chown(settings['user'],
        settings['group'], file
      )

      file_mode = file_stat.mode
      desired_mode = symbolic_mode_to_int('u+rwX,g+rX,o-rwx',file_mode,File.directory?(file))

      unless (file_mode & 007777) == desired_mode
        FileUtils.chmod(desired_mode,file)
      end
    end

    unless unowned_files.empty?
      err_msg = <<-EOM.gsub(/^\s+/,'')
        simplib::passgen: Error: Could not verify ownership by '#{settings['user']}' on the following files:
        * #{unowned_files.join("\n* ")}
      EOM

      fail(err_msg)
    end
  end
end
# vim: set expandtab ts=2 sw=2:
