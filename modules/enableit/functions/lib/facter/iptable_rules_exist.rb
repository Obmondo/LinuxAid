# iptable_rules_exist returns a bool value based on the presence of iptable rules
# on the host system 
Facter.add('iptable_rules_exist') do
  confine kernel: 'Linux'
  setcode do  
    # Only proceed if 'iptables-save' command is available  
    if Facter::Core::Execution.which('iptables-save')
      # Execute the iptables-save command and check if there's an output
      !Facter::Core::Execution.execute('iptables-save -c').strip.empty?
    else
      nil
    end
  end
end
