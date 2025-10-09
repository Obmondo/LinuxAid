# frozen_string_literal: true

Facter.add(:wireguard_pubkeys) do
  confine do
    File.directory?('/etc/wireguard/')
  end
  setcode do
    hash = {}
    Dir.glob('/etc/wireguard/*.pub').each do |file|
      filename = file.split('/').last.gsub('.pub', '')
      content = File.read(file)
      hash[filename] = content.chomp
    end
    hash
  end
end
