# Encode a string like `systemd-escape`
Puppet::Functions.create_function(:systemd_escape_path) do
  dispatch :systemd_escape_path do
    param 'String', :args
  end

  # NOTE: on purpose we are not using systemd-escape binary.
  # puppetserver is on docker
  #
  # See man systemd.unit(5) for details on algorithm.
  def systemd_escape_path(v)
    if v.size > 1 and v[0] == '/'
      s = v.slice 1, v.size
    end

    s = s.gsub(/[^A-Za-z0-9\/]/) { |m|
      # Not sure why we need to force the encoding like this, but if we don't we
      # end up with single byte encoding, and we need to have double byte.
      m.force_encoding('windows-1252')
        .encode('utf-8')
        .codepoints
        .map {|x| sprintf('\x%x', x)}.join('')
    }

    s.gsub(/\/+/, '-')

  end
end
