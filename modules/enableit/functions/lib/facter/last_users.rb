Facter.add('users_logged') do
  confine kernel: 'Linux'
  setcode do  
    # Only proceed if 'last' command is available  
    if Facter::Core::Execution.which('last')
      # Execute the last command and check details about obmondo-admin user
      Facter::Core::Execution.execute("last -w | awk '{print $1}' | sort | uniq | sed '/obmondo-admin/d; /wtmp/d; /root/d'")
    else
      nil
    end
  end
end
