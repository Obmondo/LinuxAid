Puppet::Functions.create_function(:cron_minutes_interval) do
  dispatch :minutes do
    required_param 'Integer[0, 59]', :interval
  end

  def minutes(interval)
    rand = call_function('fqdn_rand', interval)
    minutes = (rand..59).step(interval).to_a

    minutes
  end

end
