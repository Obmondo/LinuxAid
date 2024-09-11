# frozen_string_literal: true

rpm_package_re = /^(?<name>.+?)-(?<version>\d.*?)\.(?<distro>[a-z0-9]+?)\.(?<arch>[a-z0-9_]+)$/

Facter.add(:packages) do
  confine :kernel => :linux
  confine :osfamily => :redhat

  setcode do
    packages = Facter::Util::Resolution.exec('rpm -qa')

    packages.strip.split.map { |s|
      matches = s.match rpm_package_re

      Hash[rpm_package_re.names.zip(matches.captures)] if matches
    }.reduce({}) { |acc, p|
      if p
        name = p['name']
        p.delete('name')
        acc[name] = p
        acc
      else
        acc
      end
    }
  end
end

Facter.add(:packages) do
  confine :kernel => :linux
  confine :osfamily => :debian

  setcode do
    packages = Facter::Util::Resolution.exec('dpkg-query -W -f="\${binary:Package}|\${Version}|\${Architecture}\n"')

    packages.strip.split.reduce({}) { |acc, s|
      (name, version, arch) = s.split('|')
      acc[name] = {
        'version' => version,
        'arch'    => arch,
      }
      acc
    }

  end
end
