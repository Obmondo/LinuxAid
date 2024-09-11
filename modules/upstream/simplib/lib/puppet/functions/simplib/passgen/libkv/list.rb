# Using libkv, retrieves the list of generated passwords with attributes and
# the list of sub-folders stored at a simplib::passgen folder in a key/value
# store.
#
# * List operation does not recurse into sub-folders.
# * Terminates catalog compilation if any libkv operation fails.
#
Puppet::Functions.create_function(:'simplib::passgen::libkv::list') do

  # @param folder Unique `String` to identify the password sub-folder
  #   of the root folder for simplib::passgen
  #   * When unset or '', the list operation will be for the root folder
  #   * Otherwise, must conform to the following:
  #     * Identifier must contain only the following characters:
  #       * a-z
  #       * A-Z
  #       * 0-9
  #       * The following special characters: `._:-/`
  #     * Identifier may not contain '/./' or '/../' sequences.
  #
  # @param libkv_options
  #   libkv configuration that will be merged `libkv::options`.
  #   All keys are optional.
  #
  # @option libkv_options [String] 'app_id'
  #   Specifies an application name that can be used to identify which backend
  #   configuration to use via fuzzy name matching, in the absence of the
  #   `backend` option.
  #
  #     * More flexible option than `backend`.
  #     * Useful for grouping together libkv function calls found in different
  #       catalog resources.
  #     * When specified and the `backend` option is absent, the backend will be
  #       selected preferring a backend in the merged `backends` option whose
  #       name exactly matches the `app_id`, followed by the longest backend
  #       name that matches the beginning of the `app_id`, followed by the
  #       `default` backend.
  #     * When absent and the `backend` option is also absent, this function
  #       will use the `default` backend.
  #
  # @option libkv_options [String] 'backend'
  #   Definitive name of the backend to use.
  #
  #     * Takes precedence over `app_id`.
  #     * When present, must match a key in the `backends` option of the
  #       merged options Hash or the function will fail.
  #     * When absent in the merged options, this function will select
  #       the backend as described in the `app_id` option.
  #
  # @option libkv_options [Hash] 'backends'
  #   Hash of backend configurations
  #
  #     * Each backend configuration in the merged options Hash must be
  #       a Hash that has the following keys:
  #
  #       * `type`:  Backend type.
  #       * `id`:  Unique name for the instance of the backend. (Same backend
  #         type can be configured differently).
  #
  #      * Other keys for configuration specific to the backend may also be
  #        present.
  #
  # @option libkv_options [String] 'environment'
  #   Puppet environment to prepend to keys.
  #
  #     * When set to a non-empty string, it is prepended to the key used in
  #       the backend operation.
  #     * Should only be set to an empty string when the key being accessed is
  #       truly global.
  #     * Defaults to the Puppet environment for the node.
  #
  # @option libkv_options [Boolean] 'softfail'
  #   Whether to ignore libkv operation failures.
  #
  #     * When `true`, this function will return a result even when the
  #       operation failed at the backend.
  #     * When `false`, this function will fail when the backend operation
  #       failed.
  #     * Defaults to `false`.
  #
  # @return [Hash]  Hash of results or {} if folder does not exist
  #
  #   * 'keys' = Hash of password information
  #     * 'value'- Hash containing 'password' and 'salt' attributes
  #     * 'metadata' - Hash containing 'complexity', 'complex_only' and
  #       'history' attributes
  #       * 'history' is an Array of up to the last 10 <password,salt> pairs.
  #         history[0][0] is the most recent password and history[0][1] is its
  #         salt.
  #   * 'folders' = Array of sub-folder names
  #
  # @raise Exception if a libkv operation fails
  #
  dispatch :list do
    optional_param 'String', :folder
    optional_param 'Hash',   :libkv_options
  end

  def list(folder='/', libkv_options={'app_id' => 'simplib::passgen'})
    root_dir = call_function('simplib::passgen::libkv::root_dir')
    keydir = File.join(root_dir, folder)

    results = {}
    if call_function('libkv::exists', keydir, libkv_options)
      raw_results = call_function('libkv::list', keydir, libkv_options)
      results = { 'keys' => {}, 'folders' => raw_results['folders'] }
      raw_results['keys'].each do |id,info|
        if call_function('simplib::passgen::libkv::valid_password_info', info)
          results['keys'][id] = info
        else
          # only get here if someone manually inserted bad info into the
          # key/value store
          Puppet.warning("Ignoring simplib::passgen id '#{id}': incomplete info=#{info}")
        end
      end
    end

    results
  end
end

