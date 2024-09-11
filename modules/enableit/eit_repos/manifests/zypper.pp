# zypper
class eit_repos::zypper {
  confine($facts['os']['family'] != 'Suse', "${facts['os']['family']} is not supported for Suse repo")
}
