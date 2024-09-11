# @summary A function that calls the _() function in gettext. This is because _ is protected in the puppet language
#
# @note
#   Translate with simple strings:
#     - Takes in a string and passes it to fast_gettext's _() function. Primarily used for 'marking' a string to be added to a .pot file.
#   Translate with interpolation:
#     - Takes in a string and a hash. Please note that variables in the message are wrapped with %{VAR} not ${VAR}.
#     - The hash contains key value pairs with marker and the variable it will be assigned to.
#     - The translate module passes it to fast_gettext's _() function. Primarily used for 'marking' a string to be added to a .pot file.
#
# @example
#  fail(translate("Failure message"))
# @example
#  fail(translate('message is %{color}'), {'color' => 'green'})
#
Puppet::Functions.create_function(:translate) do
  # @param message Message to translate
  # @param interpolation_values Optional.
  # @return [String] translated message.
  dispatch :translate do
    param 'String', :message
    optional_param 'Hash', :interpolation_values
  end

  def translate(message, interpolation_values = nil)
    if interpolation_values.nil?
      _(message)
    else
      # convert keys to symbols
      interpolation_values = Hash[interpolation_values.map { |k, v| [k.to_sym, v] }]
      _(message) % interpolation_values
    end
  end
end
