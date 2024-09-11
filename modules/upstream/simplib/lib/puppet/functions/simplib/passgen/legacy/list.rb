# Retrieves the list of generated passwords with attributes stored
# in files on the local files system at
# `Puppet.settings[:vardir]/simp/environments/$environment/simp_autofiles/gen_passwd/`.
#
# * Any password file that cannot be accessed or for which the password
#   is empty will be ignored
# * Terminates catalog compilation if the password root directory cannot be
#   accessed by the user.
#
Puppet::Functions.create_function(:'simplib::passgen::legacy::list') do

  # @return [Hash]  Hash of results or {} if folder does not exist
  #
  #   * 'keys' = Hash of password information
  #     * 'value'- Hash containing 'password' and 'salt' attributes
  #     * 'metadata' - Hash containing other stored attributes.  Will always be empty,
  #       as the legacy simplib::passgen does not store any other attributes.
  #   * 'folders' = Array of sub-folder names.  Will always be empty, as legacy
  #     simplib::passgen does not support password identifiers prefixed with a
  #     folder path.
  #
  # @raise Exception If password root directory cannot be accessed by the user.
  #
  dispatch :list do
  end

  def list
    settings = call_function('simplib::passgen::legacy::common_settings')
    keydir = settings['keydir']

    results = {}
    if Dir.exist?(keydir)
      Dir.chdir(keydir) do
        ids = Dir.glob('*').delete_if do |id|
          # Exclude sub-directories (which legacy simplib::passgen doesn't
          # create), salt files and backup files
          File.directory?(id) || !(id =~ /(\.salt|\.last)$/).nil?
        end

        results = { 'keys' => {}, 'folders' => [] }
        ids.each do |id|
          begin
            info = call_function('simplib::passgen::legacy::get', id)
            results['keys'][id] = info unless info.empty?
          rescue Exception =>e
            Puppet.warning("Ignoring file for simplib::passgen id '#{id}': #{e.message}")
          end
        end
      end
    end

    results
  end
end
