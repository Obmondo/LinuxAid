# Create a systemd.time(7) time specification string

Puppet::Functions.create_function(:systemd_make_timespec) do
  dispatch :systemd_make_timespec do
    param 'Hash', :arg
  end

  def systemd_make_timespec(timespec)
    # join any arrays with a `,`
    tss = timespec.reduce({}) { |acc, (k, v)|
      acc[k] = Array[v].join ',' if v
      acc
    }

    out = ''

    weekday = tss['weekday']
    # apparenly an undef value in a struct can become the string `undef`, so we
    # need to handle that
    out += "#{weekday} " if weekday and weekday != 'undef'

    out += "#{tss['year']}-#{tss['month']}-#{tss['day']} #{tss['hour']}:#{tss['minute']}:#{tss['second']}"
    out
  end
end
