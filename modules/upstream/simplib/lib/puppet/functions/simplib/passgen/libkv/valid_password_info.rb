# Returns whether password information retrieved from libkv is valid
#
Puppet::Functions.create_function(:'simplib::passgen::libkv::valid_password_info') do

  # @param password_info  Hash of password information retrieved from libkv
  #   * 'value'- Hash that should contain 'password' and 'salt' attributes
  #   * 'metadata' - Hash that should contain 'complexity', 'complex_only' and
  #       'history' attributes
  #
  # @return [Boolean] Returns true if the 'value' attribute contains
  #   'password' and 'salt' attributes and the 'metadta' attribute contains
  #   'complexity', 'complex_only' and 'history' attributes
  #
  dispatch :valid_password_info do
    required_param 'Hash', :password_info
  end

  def valid_password_info(password_info)
    password_info['value'].key?('password') &&
    password_info['value'].key?('salt') &&
    password_info.key?('metadata') &&
    password_info['metadata'].key?('complexity') &&
    password_info['metadata'].key?('complex_only') &&
    password_info['metadata'].key?('history')
  end
end

