# @summary Creates post transaction configuratons for dnf or yum.
#
# @see https://dnf-plugins-core.readthedocs.io/en/latest/post-transaction-actions.html DNF Post Transaction Items
#
# @param action Name variable a string to label the rule
# @param key Package name, glob or file name file glob.
# @param state
#    Can be `install`, `update`, `remove` or `any` on YUM based systems.
#    Can be `in`, `out` or `any` on DNF based systems.
# @param command The command to run
#
# @example Touch a file when ssh is package is updated, installed or removed.
#   yum::post_transaction_action{'touch file on ssh package update':
#     key     => 'openssh-*',
#     state   => 'any',
#     command => 'touch /tmp/openssh-installed',
#   }
#
define yum::post_transaction_action (
  Variant[Enum['*'],Yum::RpmNameGlob,Stdlib::Unixpath] $key,
  String[1] $command,
  Enum['install', 'update', 'remove', 'any', 'in', 'out'] $state = 'any',
  String[1] $action = $title,
) {
  #
  # The valid Enum is different for yum and dnf based systems.
  #
  if $facts['package_provider'] == 'yum' {
    assert_type(Enum['install','update','remove','any'],$state) |$expected, $actual| {
      fail("The state parameter on ${facts['package_provider']} based systems should be \'${expected}\' and not \'${actual}\'")
    }
  } else {
    assert_type(Enum['in', 'out', 'any'],$state) |$expected, $actual| {
      fail("The state parameter on ${facts['package_provider']} based systems should be \'${expected}\' and not \'${actual}\'")
    }
  }

  require yum::plugin::post_transaction_actions

  if $yum::plugin::post_transaction_actions::ensure == 'present' {
    concat::fragment { "post_trans_${action}":
      target  => 'puppet_actions',
      content => "# Action name: ${action}\n${key}:${state}:${command}\n\n",
      order   => '10',
    }
  }
}
