# frozen_string_literal: true

Facter.add(:clientcert_pem) do
  setcode do
    File.read(Puppet.settings[:hostcert])
  end
end
