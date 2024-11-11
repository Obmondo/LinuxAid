# CIS facts

Facter.add('cis') do
  confine kernel: 'Linux'
  setcode do
    cis_facts = {}

    users_with_ids = {}
    shell_output = Facter::Core::Execution.exec("grep -E '/bin/(ba|cz)sh' /etc/passwd | cut -d ':' -f 1,3,7")

    shell_output.each_line do |line|
      username, uid, shell = line.strip.split(':')
      users_with_ids[username] = { 'id' => uid, 'shell' => shell }
    end

    cis_facts['local_users'] = users_with_ids

    telnet = Facter.value('packages.telnet') ? true : false
    rlogin = Facter.value('packages.rlogin') ? true : false
    
    cis_facts['telnet_exists'] = telnet
    cis_facts['rlogin_exists'] = rlogin
    
    cis_facts
  end
end