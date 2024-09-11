keys = [:state, :recvq, :sendq, :local_addr, :peer_addr, :users]

# map of key => fn/class for values that we want to coerce
coerce_map = {
  state: lambda { |x|
    x.downcase.to_sym
  },
  recvq: Integer,
  sendq: Integer,
}

users_re = /"(?<comm>[^"]+)",pid=(?<pid>[0-9]+),fd=(?<fd>[0-9]+)/

Facter.add(:network_ports) do
  confine :kernel => :linux
  # the output from CentOS 6.2 is apparently different and causes Puppet to
  # fail, so let's just ignore older versions.
  confine {
    os=Facter.value(:os)
    !(os['family'] == 'RedHat' && Float(os['release']['full'].match(/^\d+\.\d+/)[0]) <= 6.9)
  }
  confine { Facter::Core::Execution.which('ss') }

  setcode do
    lambda {
      lls = Facter::Util::Resolution
            .exec('ss -lpnte')
            .split("\n")[1..-1]

      # Format:
      #
      #   LISTEN 0 128 *:111 *:* users:(("rpcbind",1780,8)) ino:13436 \
      #   sk:ffff882026cd8700
      listens = lls[1..-1].reduce([]) { |acc, ll|
        item = Hash[keys.zip(ll.split(/ +/))]

        users = item[:users].match(/^users:\((.+?)\)$/)
        if users
          users = users[1][1...-1].split('),(')
          users = users.reduce([]) { |acc2, uu|
            users_matches = uu.match(users_re)
            return unless users_matches

            acc2 << Hash[users_re.names.zip(users_matches.captures)]
            acc2
          }
          item[:users] = users
        end

        acc << item
        acc
      }

      # coerce the values so we don't have integers as strings etc.
      listens = listens.map { |m|
        m.reduce({}) { |acc, (k, v)|
          f = coerce_map[k]
          acc[k] = case f
                   when nil
                     v
                   when Class
                     f.class_eval(v)
                   when Proc
                     f.call(v)
                   end

          acc
        }
      }

      return listens
    }.call
  end
end
