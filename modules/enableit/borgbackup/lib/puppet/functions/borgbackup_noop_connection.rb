require 'socket'

# Set noop to true for current and children scopes, if the socket on server port
# 22 cannot be opened.
#
# This function is inspired by the trlinkin-noop module
# (https://forge.puppet.com/trlinkin/noop)
# BEWARE: Custom changes to this module
Puppet::Functions.create_function(:borgbackup_noop_connection) do


  def borgbackup_noop_connection(server)
    begin
      TCPSocket.new(server, 22).close
      return true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ETIMEDOUT => e
      Puppet.notice "Borgbackup: Unable to connect to ssh server (#{server}): #{e.message}"
    end

  end
end
