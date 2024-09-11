# _Description_
#
# Return the minimum uid allowed
#
Facter.add('uid_min') do
  confine { File.exist?('/etc/login.defs') }

  setcode do
    uid_min = File.open('/etc/login.defs').grep(/UID_MIN/)

    # Grep returns an Array
    uid_min = '' if uid_min.empty?

    unless uid_min.empty?
      uid_min = uid_min.first.to_s.chomp.split.last
    end

    unless uid_min.empty?
      if ['RedHat','CentOS','OracleLinux','Scientific'].include?(Facter.value(:operatingsystem)) &&
         Facter.value(:operatingsystemmajrelease) < '7'
          uid_min = '500'
      else
        uid_min = '1000'
      end
    end

    uid_min
  end
end
