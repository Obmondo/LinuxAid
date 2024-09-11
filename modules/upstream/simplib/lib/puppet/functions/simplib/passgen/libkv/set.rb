# Using libkv, sets a generated password with attributes
#
# * libkv key is the identifier.
# * libkv value is a Hash with 'password' and 'salt' attributes
# * libkv metadata is a Hash with 'complexity', 'complex_only' and 'history'
#   attributes
#  * 'complexity' and 'complex_only' attributes are stored so that the password
#    to be regenerated with the same characteristics and the current password.
#  * 'history' attribute stores up to 10 most recent <password,salt> pairs.
# * Stores complexity and complex_only settings in metadata so the password can
#   be regenerated with the same characteristics and the current password
# * Maintains a history of up to 10 previous <password,salt> pairs in metadata.
# * Terminates catalog compilation if any libkv operation fails.
#
Puppet::Functions.create_function(:'simplib::passgen::libkv::set') do

  # @param identifier
  #   Unique `String` to identify the password usage.
  #   Must conform to the following:
  #   * Identifier must contain only the following characters:
  #     * a-z
  #     * A-Z
  #     * 0-9
  #     * The following special characters: `._:-/`
  #   * Identifier may not contain '/./' or '/../' sequences.
  #
  # @param password
  #   Password value
  #
  # @param salt
  #   Salt for the password for use in encryption operations
  #
  # @param complexity
  #   Specifies the types of characters in the password
  #     * `0` => Only Alphanumeric characters
  #     * `1` => Alphanumeric characters plus reasonably safe symbols
  #     * `2` => Printable ASCII
  #
  # @param complex_only
  #   Whether the password contains only the characters explicitly added by the
  #   complexity rules.  For example, when `complexity` is `1`, the password
  #   contains only safe symbols.
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
  # @return [Nil]
  # @raise Exception if a libkv operation fails
  #
  dispatch :set do
    required_param 'String[1]',    :identifier
    required_param 'String[1]',    :password
    required_param 'String[1]',    :salt
    required_param 'Integer[0,2]', :complexity
    required_param 'Boolean',      :complex_only
    optional_param 'Hash',         :libkv_options
  end

  def set(identifier, password, salt, complexity, complex_only,
      libkv_options={'app_id' => 'simplib::passgen'})

    key_root_dir = call_function('simplib::passgen::libkv::root_dir')
    key = "#{key_root_dir}/#{identifier}"
    key_info = { 'password' => password, 'salt' => salt }
    metadata = {
      'complexity'   => complexity,
      'complex_only' => complex_only,
      'history'      => get_history(identifier, libkv_options)
    }

    # TODO If libkv is updated to allow transaction locks, lock prior to
    # get_history() which calls libkv::get under the hood, and release the
    # lock after this libkv::put call.
    call_function('libkv::put', key, key_info, metadata, libkv_options)
  end

  def get_history(identifier, libkv_options)
    last_password_info = call_function('simplib::passgen::libkv::get', identifier,
      libkv_options)

    history = []
    unless last_password_info.empty?
      history = last_password_info['metadata']['history'].dup
      history.unshift([
        last_password_info['value']['password'],
        last_password_info['value']['salt']
      ])

      # only keep the last 10 <password,salt> pairs
      history = history[0..9]
    end

    history
  end
end
