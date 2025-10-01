Facter.add('users_logged') do
  setcode do

    # Only proceed further if the following conditions are met
    confine kernel: :linux
    confine { Facter::Core::Execution.which('last') }

    Facter::Core::Execution.execute("last -w | awk '{print $1}' | sort | uniq | sed '/obmondo-admin/d; /wtmp/d; /root/d'")
  end
end
