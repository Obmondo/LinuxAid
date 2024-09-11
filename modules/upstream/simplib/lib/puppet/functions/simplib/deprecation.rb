# Function to print deprecation warnings, logging a warning once
# for a given key.
#
Puppet::Functions.create_function(:'simplib::deprecation') do

  # @param key Uniqueness key, which is used to dedupe messages.
  # @param message Message to be printed, to which file and line
  #   information will be appended, if available.
  # @return [Nil]
  #
  # @example Emit a warning about a function that will be removed
  #
  #  simplib::deprecation('simplib::foo', 'simplib::foo is deprecated and will be removed in a future version')
  #
  # @example Emit a Warning about function that has been replaced
  #
  #  simplib::deprecation('simplib::foo', 'simplib::foo is deprecated.  Please use simplib::foo2 instead')
  #
  dispatch :deprecation do
    required_param 'String', :key
    required_param 'String', :message
  end

  def deprecation(key, message)
    if defined? Puppet::Pops::PuppetStack.stacktrace()
      stacktrace = Puppet::Pops::PuppetStack.stacktrace()
      file = stacktrace[0]
      line = stacktrace[1]
      message = "#{message} at #{file}:#{line}"
    end

    Puppet.deprecation_warning(message, key) unless ENV['SIMPLIB_NOLOG_DEPRECATIONS'] 
  end
end
