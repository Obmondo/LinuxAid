Puppet::Functions.create_function(:cron_range) do
  # Is current time in cron time-range
  # Timezone is UTC
  #
  # Example:
  #   cron_range('* 01-23 * * *')
  #   true/false

  dispatch :cron_range do
    param 'Array', :args
    return_type 'Array'
  end

  require 'fugit'

  def cron_range(args)
    t = Time.now.utc.strftime('%Y-%m-%d %H:%m')
    args.map do |i|
      r = Fugit::Cron.parse(i)
      r.match?(t)
    end
  end
end
