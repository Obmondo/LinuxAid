Facter.add('netbackup_client_name') do
  setcode do
    if File.exist? '/usr/openv/netbackup/bin/nbgetconfig'
      client_name = Facter::Util::Resolution.exec('/usr/openv/netbackup/bin/nbgetconfig CLIENT_NAME')
      client_name.split[2]
    elsif File.exist? '/usr/openv/netbackup/bp.conf'
      client_name = Facter::Util::Resolution.exec('/bin/grep CLIENT_NAME /usr/openv/netbackup/bp.conf')
      client_name.split[2]
    end
  end
end


Facter.add('netbackup_serverlist') do
  setcode do
    if File.exist? '/usr/openv/netbackup/bin/nbgetconfig'
      server_rows = Facter::Util::Resolution.exec('/usr/openv/netbackup/bin/nbgetconfig SERVER').split("\n")
      servers = server_rows.map! { |x| x.split[2] }
      servers
    elsif File.exist? '/usr/openv/netbackup/bp.conf'
      server_rows = Facter::Util::Resolution.exec('/bin/grep SERVER /usr/openv/netbackup/bp.conf').split("\n")
      servers = server_rows.map! { |x| x.split[2] }
      servers
    end	  
  end
end


# @todo Ugly code?
Facter.add('netbackup_version') do
  setcode do
    nbu_version = '0.0.0'

    if File.exist?('/usr/openv/netbackup/bin/version')
      File.open('/usr/openv/netbackup/bin/version', 'r') do |file|
        file.each do |line|
          if line.split.first =~ /^NetBackup.*/
            nbu_version = line.split.last
          end
        end
      end
    end

    nbu_version

  end
end
