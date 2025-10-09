# Retrieves a generated password and any stored attributes that have
# been stored in files on the local file system at
# `Puppet.settings[:vardir]/simp/environments/$environment/simp_autofiles/gen_passwd/`
#
# Terminates catalog compilation if a legacy password file is inaccessible by
# the user.
Puppet::Functions.create_function(:'simplib::passgen::legacy::get') do
  # @param identifier Unique `String` to identify the password usage.
  #   Must conform to the following:
  #   * Identifier must contain only the following characters:
  #     * a-z
  #     * A-Z
  #     * 0-9
  #     * The following special characters:  `._:-`
  #
  # @return [Hash] Password information or {} if the password does not exist
  #
  #   * 'value'- Hash containing 'password' and 'salt' attributes
  #   * 'metadata' - Hash containing 'history' attribute.
  #     * 'history' is an Array of  <password,hash> pairs that will contain at most
  #       1 entry.
  #     * No other metadata is provided in legacy mode.
  #
  # @raise Exception if a legacy password file is inaccessible by the user
  #
  dispatch :get do
    required_param 'String[1]', :identifier
  end

  def get(identifier)
    settings = call_function('simplib::passgen::legacy::common_settings')
    password, salt = get_password_info(settings['keydir'], identifier, :current)

    password_info = {}
    unless password.nil?
      password_info = { 'value' => {}, 'metadata' => { 'history' => [] } }
      password_info['value']['password'] = password
      password_info['value']['salt'] = salt

      prev_password, prev_salt = get_password_info(settings['keydir'], identifier, :previous)
      unless prev_password.nil?
        password_info['metadata']['history'] << [ prev_password, prev_salt]
      end
    end

    password_info
  end

  # Read in password and salt information from file
  def get_password_info(keydir, identifier, type)
    password_file = nil
    salt_file = nil
    if type == :current
      password_file = File.join(keydir, identifier)
      salt_file = File.join(keydir, "#{identifier}.salt")
    else
      password_file = File.join(keydir, "#{identifier}.last")
      salt_file = File.join(keydir, "#{identifier}.salt.last")
    end

    password = nil
    salt = nil
    if File.exist?(password_file)
      password = IO.readlines(password_file)[0].to_s.chomp
      if password.empty?
        password = nil
      else
        salt = if File.exist?(salt_file)
                 IO.readlines(salt_file)[0].to_s.chomp
               else
                 ''
               end
      end
    end
    [ password, salt ]
  end
end
