# Generates/retrieves a random password string or its hash for a
# passed identifier.
#
# * Password info is stored in a key/value store and accessed using simpkv.
# * The minimum length password that this function will return is `8`
#   characters.
# * Terminates catalog compilation if `password_options` contains invalid
#   parameters, any simpkv operation fails or the password cannot be created
#   in the allotted time.
#
Puppet::Functions.create_function(:'simplib::passgen::simpkv::passgen') do
  # @param identifier Unique `String` to identify the password usage.
  #   Must conform to the following:
  #   * Identifier must contain only the following characters:
  #     * a-z
  #     * A-Z
  #     * 0-9
  #     * The following special characters: `._:-/`
  #   * Identifier may not contain '/./' or '/../' sequences.
  #
  # @param password_options
  #   Password options
  #
  # @option password_options [Boolean] 'last'
  #   Whether to return the last generated password.
  #   Defaults to `false`.
  # @option password_options [Integer[8]] 'length'
  #   Length of the new password.
  #   Defaults to `32`.
  # @option password_options [Enum[true,false,'md5',sha256','sha512']] 'hash'
  #   Return a `Hash` of the password instead of the password itself.
  #   Defaults to `false`.  `true` is equivalent to 'sha256'.
  # @option password_options [Integer[0,2]] 'complexity'
  #   Specifies the types of characters to be used in the password
  #     * `0` => Default. Use only Alphanumeric characters in your password (safest)
  #     * `1` => Add reasonably safe symbols
  #     * `2` => Printable ASCII
  # @option password_options [Boolean] 'complex_only'
  #   Whether to use only the characters explicitly added by the complexity
  #   rules.  For example, when `complexity` is `1`, create a password from only
  #   safe symbols.
  #   Defaults to `false`.
  # @option password_options [Variant[Integer[0],Float[0]]] 'gen_timeout_seconds'
  #   Maximum time allotted to generate the password.
  #     * Value of `0` disables the timeout.
  #     * Defaults to `30`.
  #
  # @param simpkv_options simpkv configuration that will be merged with
  #   `simpkv::options`.  All keys are optional.
  #
  # @option simpkv_options [String] 'app_id'
  #   Specifies an application name that can be used to identify which backend
  #   configuration to use via fuzzy name matching, in the absence of the
  #   `backend` option.
  #
  #     * More flexible option than `backend`.
  #     * Useful for grouping together simpkv function calls found in different
  #       catalog resources.
  #     * When specified and the `backend` option is absent, the backend will be
  #       selected preferring a backend in the merged `backends` option whose
  #       name exactly matches the `app_id`, followed by the longest backend
  #       name that matches the beginning of the `app_id`, followed by the
  #       `default` backend.
  #     * When absent and the `backend` option is also absent, this function
  #       will use the `default` backend.
  #
  # @option simpkv_options [String] 'backend'
  #   Definitive name of the backend to use.
  #
  #     * Takes precedence over `app_id`.
  #     * When present, must match a key in the `backends` option of the
  #       merged options Hash or the function will fail.
  #     * When absent in the merged options, this function will select
  #       the backend as described in the `app_id` option.
  #
  # @option simpkv_options [Hash] 'backends'
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
  # @option simpkv_options [String] 'environment'
  #   Puppet environment to prepend to keys.
  #
  #     * When set to a non-empty string, it is prepended to the key used in
  #       the backend operation.
  #     * Should only be set to an empty string when the key being accessed is
  #       truly global.
  #     * Defaults to the Puppet environment for the node.
  #
  # @option simpkv_options [Boolean] 'softfail'
  #   Whether to ignore simpkv operation failures.
  #
  #     * When `true`, this function will return a result even when the
  #       operation failed at the backend.
  #     * When `false`, this function will fail when the backend operation
  #       failed.
  #     * Defaults to `false`.
  #
  #
  # @return [String] Password or password hash specified.
  #
  #   * When the `last` password option is `true`, the password is determined
  #     as follows:
  #
  #     * If the last password exists in the key/value store, uses the existing
  #       last password.
  #     * Otherwise, if the current password exists in the key/value store,
  #       uses the existing current password.
  #     * Otherwise, creates and stores a new password as the current password,
  #       and then uses this new password
  #
  #   * When `last` option is `false`, the password is determined as follows:
  #
  #     * If the current password doesn't exist in the key/value store, creates
  #       and stores a new password as the current password, and then uses this
  #       new password.
  #     * Otherwise, if the current password exists in the key/value store and it
  #       has an appropriate length, uses the current password.
  #     * Otherwise, stores the current password as the last password, creates
  #       and stores a new password as the current password, and then uses this
  #       new password.
  #
  # @raise Exception if `password_options` contains invalid parameters,
  #   a simpkv operation fails, or password generation times out
  #
  dispatch :passgen do
    required_param 'String[1]', :identifier
    optional_param 'Hash',      :password_options
    optional_param 'Hash',      :simpkv_options
  end

  def passgen(identifier, password_options = {}, simpkv_options = { 'app_id' => 'simplib::passgen' })
    require 'timeout'

    # internal settings
    settings = {}
    settings['min_password_length'] = 8
    settings['default_password_length'] = 32
    settings['crypt_map'] = {
      'md5'     => '1',
      'sha256'  => '5',
      'sha512'  => '6',
    }

    base_options = {
      'last'                => false,
      'length'              => settings['default_password_length'],
      'hash'                => false,
      'complexity'          => 0,
      'complex_only'        => false,
      'gen_timeout_seconds' => 30,
    }

    options = build_options(base_options, password_options, settings)

    password = nil
    salt = nil
    begin
      if options['last']
        password, salt = get_last_password(identifier, options, simpkv_options)
      else
        password, salt = get_current_password(identifier, options, simpkv_options)
      end
    rescue Timeout::Error
      # can get here if password/salt generation timed out
      raise("simplib::passgen timed out for '#{identifier}'!")
    end

    # Return the hash, not the password
    return password.crypt("$#{settings['crypt_map'][options['hash']]}$#{salt}") if options['hash']

    password
  end

  # Build a merged options hash and validate the options
  # @raise ArgumentError if any option in the password_options is invalid
  def build_options(base_options, password_options, settings)
    options = base_options.dup
    options.merge!(password_options)

    # set internal options that help us validate whether a retrieved
    # password meets current criteria
    options['length_configured'] = password_options.key?('length')
    options['complexity_configured'] = password_options.key?('complexity')
    options['complex_only_configured'] = password_options.key?('complex_only')

    if !%r{^\d+$}.match?(options['length'].to_s)
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

    if !%r{^\d+$}.match?(options['complexity'].to_s)
      raise ArgumentError,
        "simplib::passgen: Error: Complexity '#{options['complexity']}' must be an integer!"
    else
      options['complexity'] = options['complexity'].to_i
    end

    if !%r{^\d+$}.match?(options['gen_timeout_seconds'].to_s)
      raise ArgumentError,
        "simplib::passgen: Error: Password generation timeout '#{options['gen_timeout_seconds']}' must be an integer!"
    else
      options['gen_timeout_seconds'] = options['gen_timeout_seconds'].to_i
    end

    # Make sure a valid hash has been selected
    if options['hash'] == true
      options['hash'] = 'sha256'
    end
    if options['hash'] && !settings['crypt_map'].keys.include?(options['hash'])
      raise ArgumentError,
       "simplib::passgen: Error: '#{options['hash']}' is not a valid hash."
    end

    options
  end

  # Create a <password,salt> pair and then store it, pertinent options, and
  # any <password,salt> history in the key/value store
  #
  # @param identifier Password name
  # @param options Hash of options to use to generate the password
  #
  # @return [password, salt]
  # @raise Timeout::Error if password or salt generation times out
  # @raise Exception if simpkv operation fails
  def create_and_store_password(identifier, options, simpkv_options)
    password, salt = call_function('simplib::passgen::gen_password_and_salt',
      options['length'],
      options['complexity'],
      options['complex_only'],
      options['gen_timeout_seconds'])

    call_function('simplib::passgen::simpkv::set',
      identifier, password, salt, options['complexity'],
      options['complex_only'], simpkv_options)

    [password, salt]
  end

  # Retrieve or generate a current password and its salt
  #
  # * If the current password doesn't exist in the key/value store, generate
  #   both the password and its salt and store them in the key/value store.
  # * If the current password exists, retrieve it and its salt from the
  #   key/value store, and validate it.
  #   * If the password has the correct length per the options, use it.
  #   * Otherwise, store this password and its salt as the last password in
  #     the key/value store, generate a new the password and salt, and then
  #     store the new values as the current password in the key/value store.
  #
  # @return current [password, salt]
  # @raise if any simpkv operation fails or password/salt generation times out.
  #
  def get_current_password(identifier, options, simpkv_options)
    password = nil
    salt = nil
    generate = false

    password_info = call_function('simplib::passgen::simpkv::get', identifier,
      simpkv_options)

    if password_info.empty?
      generate = true
    else
      password = password_info['value']['password']
      salt = password_info['value']['salt']
      generate = true unless valid_password?(password_info, options)
    end

    if generate
      password, salt = create_and_store_password(identifier, options,
        simpkv_options)
    end

    [password, salt]
  end

  # Retrieve lastest password and its salt, generating the password
  # if needed
  #
  #  * If the password key exists in the key/value and the history is not
  #    empty, use the first entry from that history (i.e., most recent
  #    <password,salt> pair).
  #  * Otherwise, if the password key exists in the key/value and the history
  #    is empty, use the current password and salt
  #  * Otherwise, create a freshly-generated password and salt, store it
  #    in the key/value store and warn the user about a probable manifest
  #    ordering problems.
  #
  # @return last [password, salt]
  # @raise if any simpkv operation fails or password/salt generation times out.
  #
  def get_last_password(identifier, options, simpkv_options)
    password = nil
    salt = nil

    password_info = call_function('simplib::passgen::simpkv::get', identifier, simpkv_options)

    if password_info.empty?
      warn_msg = 'Could not retrieve a last or current value for' \
                 " #{identifier}. Generating a new value for 'last'. Please ensure" \
                 ' that you have used simplib::passgen in the proper order in your' \
                 ' manifest!'
      Puppet.warning warn_msg
      # generate password and salt and then store
      password, salt = create_and_store_password(identifier, options,
        simpkv_options)
    elsif !password_info['metadata']['history'].empty?
      password, salt = password_info['metadata']['history'].first
    else
      password = password_info['value']['password']
      salt = password_info['value']['salt']
    end

    [password, salt]
  end

  # @return whether a retrieved password conforms to the current user
  #   specification
  # @param password_info password info Hash
  # @param options current options
  def valid_password?(password_info, options)
    if options['length_configured']
      unless password_info['value']['password'].length == options['length']
        return false
      end
    end

    if options['complexity_configured']
      unless password_info['metadata'].key?('complexity') &&
             (password_info['metadata']['complexity'] == options['complexity'])
        return false
      end
    end

    if options['complex_only_configured']
      unless password_info['metadata'].key?('complex_only') &&
             (password_info['metadata']['complex_only'] == options['complex_only'])
        return false
      end
    end

    true
  end
end
