# @summary Default firewall configuration for Docker-CE
#
# The configuration distributed in this class represents the default firewall
# configuration done by docker-ce when the iptables integration is enabled.
#
# This class is needed as the default docker-ce rules added to ip-filter conflict
# with the inet-filter forward rules set by default in this module.
#
# When using this class 'docker::iptables: false' should be set.
#
# @param docker_interface
#   Interface name used by docker.
# @param docker_prefix
#   The address space used by docker.
# @param manage_docker_chains
#   Flag to control whether the class should create the docker related chains.
# @param manage_base_chains
#   Flag to control whether the class should create the base common chains.
class nftables::rules::docker_ce (
  String[1]                     $docker_interface     = 'docker0',
  Stdlib::IP::Address::V4::CIDR $docker_prefix        = '172.17.0.0/16',
  Boolean                       $manage_docker_chains = true,
  Boolean                       $manage_base_chains   = true,
) {
  #
  # inet-filter
  #
  if $manage_docker_chains {
    nftables::chain {
      'DOCKER': ;
      'DOCKER_ISOLATION_STAGE_1': ;
      'DOCKER_ISOLATION_STAGE_2': ;
      'DOCKER_USER': ;
    }
  }

  nftables::rule {
    'DOCKER_ISOLATION_STAGE_1-iifname':
      order   => '01',
      content => "iifname \"${docker_interface}\" oifname != \"${docker_interface}\" counter jump DOCKER_ISOLATION_STAGE_2";
    'DOCKER_ISOLATION_STAGE_1-counter':
      order   => '02',
      content => 'counter return';
    'DOCKER_ISOLATION_STAGE_2-drop':
      order   => '01',
      content => "oifname \"${docker_interface}\" counter drop";
    'DOCKER_ISOLATION_STAGE_2-counter':
      order   => '02',
      content => 'counter return';
    'DOCKER_USER-counter':
      order   => '01',
      content => 'counter return',
  }

  nftables::rule {
    'default_fwd-jump_docker_user':
      order   => '40',
      content => 'counter jump DOCKER_USER';
    'default_fwd-jump_docker_isolation_stage_1':
      order   => '41',
      content => 'counter jump DOCKER_ISOLATION_STAGE_1';
    'default_fwd-out_docker_accept':
      order   => '42',
      content => "oifname \"${docker_interface}\" ct state established,related counter accept";
    'default_fwd-jump_docker':
      order   => '43',
      content => "oifname \"${docker_interface}\" counter jump DOCKER";
    'default_fwd-idocker_onot_accept':
      order   => '44',
      content => "iifname \"${docker_interface}\" oifname != \"${docker_interface}\" counter accept";
    'default_fwd-idocker_odocker_accept':
      order   => '45',
      content => "iifname \"${docker_interface}\" oifname \"${docker_interface}\" counter accept";
  }

  #
  # ip-nat
  #

  if $manage_docker_chains {
    nftables::chain {
      "DOCKER-${nftables::nat_table_name}":
        table => "ip-${nftables::nat_table_name}",
        chain => 'DOCKER';
    }
  }

  if $manage_base_chains {
    nftables::chain {
      "OUTPUT-${nftables::nat_table_name}":
        table => "ip-${nftables::nat_table_name}",
        chain => 'OUTPUT';
      "INPUT-${nftables::nat_table_name}":
        table => "ip-${nftables::nat_table_name}",
        chain => 'INPUT';
    }
  }

  nftables::rule {
    'POSTROUTING-docker':
      table   => "ip-${nftables::nat_table_name}",
      content => "oifname != \"${docker_interface}\" ip saddr ${docker_prefix} counter masquerade";
    'PREROUTING-docker':
      table   => "ip-${nftables::nat_table_name}",
      content => 'fib daddr type local counter jump DOCKER';
    "OUTPUT-jump_docker@ip-${nftables::nat_table_name}":
      rulename => 'OUTPUT-jump_docker',
      table    => "ip-${nftables::nat_table_name}",
      content  => 'ip daddr != 127.0.0.0/8 fib daddr type local counter jump DOCKER';
    'DOCKER-counter':
      table   => "ip-${nftables::nat_table_name}",
      content => "iifname \"${docker_interface}\" counter return";
    "INPUT-type@ip-${nftables::nat_table_name}":
      rulename => 'INPUT-type',
      table    => "ip-${nftables::nat_table_name}",
      order    => '01',
      content  => 'type nat hook input priority 100';
    "INPUT-policy@ip-${nftables::nat_table_name}":
      rulename => 'INPUT-policy',
      table    => "ip-${nftables::nat_table_name}",
      order    => '02',
      content  => 'policy accept';
  }
}
