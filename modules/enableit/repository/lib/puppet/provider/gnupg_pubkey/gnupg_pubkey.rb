require 'etc'
require 'tmpdir'
require 'puppet/file_serving/content'

Puppet::Type.type(:gnupg_pubkey).provide(:gnupg_pubkey) do

  @doc = 'Provider for gnupg_pubkey type.'

  defaultfor :kernel => 'Linux'
  confine :kernel => 'Linux'

  def self.instances
    []
  end

  # although we do not use the commands class it's used to detect if the gpg and
  # awk commands are installed on the system
  commands :gpg => 'gpg'
  commands :awk => 'awk'

  def keyring_file

    case resource[:keyring_file]
    when /^~\//
      File.expand_path("~"+resource[:user]+"/"+(resource[:keyring_file].to_s[2..-1]))

    when /^\//
      resource[:keyring_file]
    else
      raise Puppet::Error, "Keyring file path must either start with tilde (~) or be an absolute path."
    end
  end

  def gpg_custom_keyring
    "--no-default-keyring --keyring #{keyring_file}"
  end

  def remove_key
    begin
      fingerprint_command = "gpg #{gpg_custom_keyring} --fingerprint --with-colons #{resource[:key_id]} | awk -F: '$1 == \"fpr\" {print $10;}'"
      fingerprint = Puppet::Util::Execution.execute(fingerprint_command, :uid => user_id)
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "Could not determine fingerprint for  #{resource[:key_id]} for user #{resource[:user]}: #{fingerprint}"
    end

    command = "gpg #{gpg_custom_keyring} --batch --yes --delete-key #{fingerprint}"

    begin
      output = Puppet::Util::Execution.execute(command, :uid => user_id)
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "Could not remove #{resource[:key_id]} for user #{resource[:user]}: #{output}"
    end
  end

  # where most of the magic happens
  def add_key
    if resource[:key_server]
      add_key_from_key_server
    elsif resource[:key_source]
      add_key_from_key_source
    elsif resource[:key_content]
      add_key_from_key_content
    end
  end

  def add_key_from_key_server
    command = "gpg #{gpg_custom_keyring} --keyserver #{resource[:key_server]} --recv-keys #{resource[:key_id]}"
    output = Puppet::Util::Execution.execute(command, :uid => user_id)
    return output if output.exitstatus == 0 || output.exitstatus == 2

    raise Puppet::Error, "Key #{resource[:key_id]} does not exist on #{resource[:key_server]}"
  end

  def add_key_from_key_source
    if Puppet::Util.absolute_path?(resource[:key_source])
      add_key_at_path
    else
      add_key_at_url
    end
  end

  def add_key_from_key_content
    path = create_temporary_file(user_id, resource[:key_content])
    command = "gpg #{gpg_custom_keyring} --batch --import #{path}"
    output = Puppet::Util::Execution.execute(command, :uid => user_id)
    return output if output.exitstatus == 0 || output.exitstatus == 2

    raise Puppet::Error, "Error while importing key #{resource[:key_id]} using key content:\n#{output}}"
  end

  def add_key_at_path
    if File.file?(resource[:key_source])
      command = "gpg #{gpg_custom_keyring} --batch --import #{resource[:key_source]}"
      begin
        output = Puppet::Util::Execution.execute(command, :uid => user_id, :failonfail => true)
      rescue Puppet::ExecutionFailure => e
        raise Puppet::Error, "Error while importing key #{resource[:key_id]} from #{resource[:key_source]}"
      end
    elsif
      raise Puppet::Error, "Local file #{resource[:key_source]} for #{resource[:key_id]} does not exists"
    end
  end

  def add_key_at_url
    if URI.const_defined? 'DEFAULT_PARSER'
      uri = URI.parse(URI::DEFAULT_PARSER.escape(resource[:key_source]))
    else
      uri = URI.parse(URI.escape(resource[:key_source]))
    end
    case uri.scheme
    when /https/
      command = "wget -O- #{resource[:key_source]} | gpg #{gpg_custom_keyring} --batch --import"
    when /http/
      command = "gpg #{gpg_custom_keyring} --fetch-keys #{resource[:key_source]}"
    when 'puppet'
      path = create_temporary_file user_id, puppet_content
      command = "gpg #{gpg_custom_keyring} --batch --import #{path}"
    end
    begin
      output = Puppet::Util::Execution.execute(command, :uid => user_id, :failonfail => true)
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "Error while importing key #{resource[:key_id]} from #{resource[:key_source]}:\n#{output}}"
    end
  end

  def user_id
    begin
      Etc.getpwnam(resource[:user]).uid
    rescue => e
      raise Puppet::Error, "User #{resource[:user]} does not exists"
    end
  end

  def create_temporary_file user_id, content
    Puppet::Util::SUIDManager.asuser(user_id) do
      tmpfile = Tempfile.open(['golja-gnupg', 'key'])
      tmpfile.write(content)
      tmpfile.flush
      break tmpfile.path.to_s
    end
  end

  def puppet_content
    # Look up (if necessary) and return remote content.
    return @content if @content
    unless tmp = Puppet::FileServing::Content.indirection.find(resource[:key_source], :environment => resource.catalog.environment, :links => :follow)
      fail "Could not find any content at %s" % resource[:key_source]
    end
    @content = tmp.content
  end

  def exists?
    command= "gpg #{gpg_custom_keyring} --list-keys --with-colons #{resource[:key_id]}"

    output = Puppet::Util::Execution.execute(command, :uid => user_id)
    if output.exitstatus == 0
      return true
    end

    if output.exitstatus == 2
      return false
    end

    raise Puppet::Error, "Non recognized exit status from GnuPG #{output.exitstatus} #{output}"
  end

  def create
    add_key
  end

  def destroy
    remove_key
  end
end
