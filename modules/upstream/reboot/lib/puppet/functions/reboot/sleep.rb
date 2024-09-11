# Sleeps for specified number of seconds.
Puppet::Functions.create_function(:'reboot::sleep') do
  # @param period Time to sleep (in seconds)
  dispatch :sleeper do
    required_param 'Integer', :period
  end

  def sleeper(period)
    sleep(period)
  end
end
