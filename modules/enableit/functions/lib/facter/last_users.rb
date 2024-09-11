Facter.add('users_logged') do
  setcode do
    Facter::Core::Execution.execute("last -w | awk '{print $1}' | sort | uniq | sed '/obmondo-admin/d; /wtmp/d; /root/d'")
  end
end
