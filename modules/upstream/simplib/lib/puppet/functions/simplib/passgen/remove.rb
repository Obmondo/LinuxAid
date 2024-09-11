# Removes a generated password, history and stored attributes
#
# * Supports 2 modes:
#   * libkv
#     * Password info is stored in a key/value store and removed using libkv.
#       * libkv key is the identifier.
#     * Terminates catalog compilation if any libkv operation fails.
#
#   * Legacy
#     * Password info is stored in files on the local file system at
#       `Puppet.settings[:vardir]/simp/environments/$environment/simp_autofiles/gen_passwd/`.
#       * Password is stored in a file named for the identifier.
#       * Salt is stored in a separate file named <identifier>.salt`.
#       * Backups of the password and salt are files ending with '.last'.
#     * Removes all password and salt files for the identifier.
#     * Terminates catalog compilation if any password files cannot be
#       removed by the user.
#
# * To enable libkv implementation, set `simplib::passgen::libkv` to `true`
#   in hieradata. When that setting absent or false, legacy mode will be used.
#
Puppet::Functions.create_function(:'simplib::passgen::remove') do

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
  # @param libkv_options
  #   libkv configuration when in libkv mode.
  #
  #     * Will be merged with `libkv::options`.
  #     * All keys are optional.
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
  #
  # @return [Nil]
  # @raise Exception if a libkv operation fails or any legacy password file
  #   cannot be removed
  #
  dispatch :remove do
    required_param 'String[1]', :identifier
    optional_param 'Hash',      :libkv_options
  end

  def remove(identifier, libkv_options={'app_id' => 'simplib::passgen'})
    use_libkv = call_function('lookup', 'simplib::passgen::libkv',
      { 'default_value' => false })

    if use_libkv
      call_function('simplib::passgen::libkv::remove', identifier, libkv_options)
    else
      call_function('simplib::passgen::legacy::remove', identifier)
    end
  end
end
