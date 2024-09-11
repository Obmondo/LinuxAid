# @summary Class to install post_transaction plugin
#
# @see https://dnf-plugins-core.readthedocs.io/en/latest/post-transaction-actions.html DNF Post Transaction Items
#
# @param ensure Should the post_transaction actions plugin be installed
#
# @example Enable post_transaction_action plugin
#   class{'yum::plugin::post_transaction_actions':
#     ensure => present,
#   }
#
class yum::plugin::post_transaction_actions (
  Enum['present', 'absent'] $ensure = 'present',
) {
  if $facts['package_provider'] == 'yum' {
    $_pkg_prefix  = undef
    $_actionfile = '/etc/yum/post-actions/puppet_maintained.action'
  } else {
    $_pkg_prefix  = 'python3-dnf-plugin'
    $_actionfile = '/etc/dnf/plugins/post-transaction-actions.d/puppet_maintained.action'
  }

  yum::plugin { 'post-transaction-actions':
    ensure     => $ensure,
    pkg_prefix => $_pkg_prefix,
  }

  if $ensure == 'present' {
    concat { 'puppet_actions':
      ensure => present,
      path   => $_actionfile,
      owner  => root,
      group  => root,
      mode   => '0644',
    }

    concat::fragment { 'action_header':
      target  => 'puppet_actions',
      content => "# Puppet maintained actions\n# \$key:\$state:\$command\n\n",
      order   => '01',
    }
  }
}
