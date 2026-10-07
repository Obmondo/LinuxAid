# frozen_string_literal: true

#
# Produce an array of nftables.
# nft list tables
# table inet filter
# table ip nat
# table ip6 nat
# table inet f2b-table
#
# Produce the version of nftables (nft --version)
# nftables v0.9.3 (Topsy)
#
Facter.add(:nftables) do
  @nft_cmd = Facter::Core::Execution.which('nft')
  confine { @nft_cmd }

  setcode do
    tables = []
    table_result = Facter::Core::Execution.execute(%(#{@nft_cmd} list tables))
    table_result.each_line do |line|
      tables.push(line.split[1, 2].join('-'))
    end
    version = Facter::Core::Execution.execute(%(#{@nft_cmd} --version))[%r{^.*v(\d+\.\d+.\d+)\s.*$}, 1]
    {
      'tables' => tables,
      'version' => version,
    }
  end
end
