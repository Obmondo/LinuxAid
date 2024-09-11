Facter.add("passenger_version") do
  confine :osfamily => 'RedHat'
  setcode do
    Facter::Util::Resolution.exec('passenger -v 2>/dev/null | head -n 1 | awk \'{print $NF}\'')
  end
end
