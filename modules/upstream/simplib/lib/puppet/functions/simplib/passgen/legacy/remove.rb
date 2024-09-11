# Removes a generated password, history and stored attributes
#
# * Password info is stored in files on the local file system at
#   `Puppet.settings[:vardir]/simp/environments/$environment/simp_autofiles/gen_passwd/`.
#   * Password is stored in a file named for the identifier.
#   * Salt is stored in a separate file named <identifier>.salt`.
#   * Backups of the password and salt are files ending with '.last'.
# * Removes all password and salt files for the identifier.
# * Terminates catalog compilation if any password files cannot be
#   removed by the user.
#
Puppet::Functions.create_function(:'simplib::passgen::legacy::remove') do

  # @param identifier Unique `String` to identify the password usage.
  #   Must conform to the following:
  #   * Identifier must contain only the following characters:
  #     * a-z
  #     * A-Z
  #     * 0-9
  #     * The following special characters:
  #       * `._:-` for the legacy implementation
  #       * `._:-/` for the libkv-enabled implementation
  #   * Identifier may not contain '/./' or '/../' sequences.
  #
  # @return [Nil]
  # @raise Exception any legacy password file cannot be removed
  #
  dispatch :remove do
    required_param 'String[1]', :identifier
  end

  def remove(identifier)
    settings = call_function('simplib::passgen::legacy::common_settings')
    keydir = settings['keydir']

    password_files = [
      File.join(keydir, identifier),
      File.join(keydir, "#{identifier}.salt"),
      File.join(keydir, "#{identifier}.last"),
      File.join(keydir, "#{identifier}.salt.last"),
      File.join(keydir, "#{identifier}.last.last"),
      File.join(keydir, "#{identifier}.salt.last.last")
    ]

    failures = []
    password_files.each do |file|
      if File.exist?(file)
        begin
          File.unlink(file)
        rescue Exception => e
          failures << "#{file}: #{e.message}"
        end
      end
    end

    unless failures.empty?
      msg = "Unable to remove all files:\n#{failures.join("\n")}"
      raise("simplib::passgen::legacy::delete failed: #{msg}")
    end
  end
end
