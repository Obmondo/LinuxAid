Facter.add(:kolab_password) do
  setcode do
    lambda {
      filename = '/etc/kolab/installation_password'
      return if not File.file?(filename)
      kolab = Hash.new
      begin
        File.open(filename, 'r') do |f|
          f.each_line do |line|
            next if line =~ /MySQL root/i
            if line =~ /password/
              get_password = line.tr('[]:','').split.last
              password_of = line.tr('[]:','').split.first(2).join(" ").to_s
              kolab[password_of] = get_password
            end
          end
        end

        kolab
      end
    }.call
  end
end

if Facter.value(:kolab_password)
  Facter.add(:kolab_admin_password) do
    setcode do
      Facter.value(:kolab_password)['Administrator password']
    end
  end

  Facter.add(:kolab_cyrus_admin_password) do
    setcode do
      Facter.value(:kolab_password)['Cyrus Administrator']
    end
  end

  Facter.add(:kolab_service_password) do
    setcode do
      Facter.value(:kolab_password)['Kolab Service']
    end
  end

  Facter.add(:kolab_mysql_kolab_password) do
    setcode do
      Facter.value(:kolab_password)['MySQL kolab']
    end
  end

  Facter.add(:kolab_mysql_roundcube) do
    setcode do
      Facter.value(:kolab_password)['MySQL roundcube']
    end
  end
end
