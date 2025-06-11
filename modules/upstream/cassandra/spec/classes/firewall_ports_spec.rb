require 'spec_helper'
describe 'cassandra::firewall_ports' do
  context 'Run with defaults.' do
    it do
      is_expected.to have_resource_count(2)
      is_expected.to contain_firewall('200 - Cassandra (Public) - 0.0.0.0/0')

      is_expected.to contain_class('cassandra::firewall_ports').with(
        client_ports: [9042, 9160],
        client_subnets: ['0.0.0.0/0'],
        inter_node_ports: [7000, 7001, 7199],
        inter_node_subnets: ['0.0.0.0/0'],
        public_ports: [8888],
        public_subnets: ['0.0.0.0/0'],
        ssh_port: 22,
        opscenter_ports: [9042, 9160, 61_620, 61_621],
        opscenter_subnets: ['0.0.0.0/0']
      )

      is_expected.to contain_cassandra__private__firewall_ports__rule('200_Public_0.0.0.0/0').with(ports: [8888, 22])
    end
  end
end
