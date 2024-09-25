# iptable_rules_exist returns a bool value based on the presence of iptable rules
# on the host system 
Facter.add('iptable_rules_exist') do
  setcode do

    # Only proceed further if the following conditions are met
    confine kernel: :linux
    confine { Facter::Core::Execution.which('iptables-save') }

    # Execute the iptables-save command and check if there's an output
    !Facter::Core::Execution.execute('iptables-save -c').strip.empty?

  end
end
