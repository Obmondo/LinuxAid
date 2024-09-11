Puppet::Functions.create_function(:timeroncalendar) do
  dispatch :timeroncalendar do
    param 'Eit_types::SystemdTimer::Weekday', :weekday
    param 'Eit_types::SystemdTimer::Year', :year
    param 'Eit_types::SystemdTimer::Month', :month
    param 'Eit_types::SystemdTimer::Day', :day
    param 'Eit_types::SystemdTimer::Hour', :hour
    param 'Eit_types::SystemdTimer::Minute', :minute
  end

  def formatdate(s)
    case s
    when Array
      s.join(",")
    when String
      s
    when Integer
      s.to_s
    end
  end

  def timeroncalendar(weekday, year, month, day, hour, minute)
    formatdate(weekday) + " " + year  + '-' + formatdate(month) + '-' + formatdate(day) + ' ' + formatdate(hour) + ':' + formatdate(minute) + ':' + "00"
  end
end
