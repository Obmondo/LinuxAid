# Stores a generated password and salt in files on the local filesystem at
# `Puppet.settings[:vardir]/simp/environments/$environment/simp_autofiles/gen_passwd/`.
#
# * Sets the password and salt
#   * Password is stored in a file named for the identifier.
#   * Salt is stored in a separate file named <identifier>.salt`.
# * Backs up previous password and salt files
#   * Backup files are named `<identifier>.last` and <identifier>.salt.last`.
# * Terminates catalog compilation if any password files cannot be created/modified by the user.
#
Puppet::Functions.create_function(:'simplib::passgen::legacy::set') do
  # @param identifier Unique `String` to identify the password usage.
  #   Must conform to the following:
  #   * Identifier must contain only the following characters:
  #     * a-z
  #     * A-Z
  #     * 0-9
  #     * The following special characters: `._:-`
  #
  # @param password
  #   Password value
  #
  # @param salt
  #   Salt for the password for use in encryption operations
  #
  # @param user
  #   User for generated files/directories
  #     * Defaults to the user compiling the catalog.
  #     * Only useful when running `puppet apply` as the `root` user.
  #
  # @param group
  #   Group for generated files/directories
  #     * Defaults to the group compiling the catalog.
  #     * Only useful when running `puppet apply` as the `root` user.
  #
  # @return [Nil]
  # @raise Exception if any legacy password files cannot be be created/modified
  #   by the user.
  #
  dispatch :set do
    required_param 'String[1]', :identifier
    required_param 'String[1]', :password
    required_param 'String[1]', :salt
    optional_param 'String[1]', :user
    optional_param 'String[1]', :group
  end

  def set(identifier, password, salt, user = nil, group = nil)
    settings = call_function('simplib::passgen::legacy::common_settings')

    # override settings for user and group when those parameters are set
    settings['user'] = user unless user.nil?
    settings['group'] = group unless group.nil?

    keydir = settings['keydir']

    set_up_keydir(settings) unless File.directory?(keydir)
    backup_password_info(keydir, identifier)
    set_password_info(settings, identifier, password, salt)
  end

  def backup_password_info(keydir, identifier)
    password_info = call_function('simplib::passgen::legacy::get', identifier)
    # No current password to backup
    return if password_info.empty?

    files = transaction_filenames(keydir, identifier)

    # 'prev_prev' is for manual, transaction rollback. (Not worth the time to
    # implement automatic rollback for the legacy mode!)
    if password_info['metadata']['history'].empty?
      # Just in case files hanging around from some partial, manual operation,
      # remove OBE files.  We want to make sure we are clean for any manual
      # transaction rollback operation.
      FileUtils.rm_f(files['prev_prev_password'])
      FileUtils.rm_f(files['prev_prev_salt'])
    else
      move_files(files, 'prev_', 'prev_prev_')
    end
    move_files(files, '', 'prev_')
  end

  def move_files(files, source_prefix, dest_prefix)
    FileUtils.mv(files["#{source_prefix}password"], files["#{dest_prefix}password"], force: true)

    if File.exist?(files["#{source_prefix}salt"])
      FileUtils.mv(files["#{source_prefix}salt"], files["#{dest_prefix}salt"], force: true)
    else
      # make sure we are clean for manual transaction rollback if needed
      FileUtils.rm_f(files["#{dest_prefix}salt"])
    end
  end

  def set_password_info(settings, identifier, password, salt)
    files = transaction_filenames(settings['keydir'], identifier)
    write_file(files['password'], password, settings)
    write_file(files['salt'], salt, settings)
  end

  # Create keydir and set permissions
  # @raise RuntimeError if fails to create or set permissions on keydir
  def set_up_keydir(settings)
    FileUtils.mkdir_p(settings['keydir'], mode: settings['dir_mode'])
    FileUtils.chown(settings['user'], settings['group'], settings['keydir'])
  rescue SystemCallError => e
    err_msg = 'simplib::passgen::legacy::set: Could not make directory' \
              " #{settings['keydir']}:  #{e.message}. Ensure that" \
              " #{File.dirname(settings['keydir'])} is writable by" \
              " '#{settings['user']}'"
    raise(err_msg)
  end

  def transaction_filenames(keydir, identifier)
    {
      'password'           => File.join(keydir, identifier),
      'salt'               => File.join(keydir, "#{identifier}.salt"),
      'prev_password'      => File.join(keydir, "#{identifier}.last"),
      'prev_salt'          => File.join(keydir, "#{identifier}.salt.last"),
      # for manual transaction rollback
      'prev_prev_password' => File.join(keydir, "#{identifier}.last.last"),
      'prev_prev_salt'     => File.join(keydir, "#{identifier}.salt.last.last"),
    }
  end

  def write_file(file, content, settings)
    File.open(file, 'w') { |fh| fh.puts content }
    File.chmod(settings['file_mode'], file)
    FileUtils.chown(settings['user'], settings['group'], file)
  end
end
