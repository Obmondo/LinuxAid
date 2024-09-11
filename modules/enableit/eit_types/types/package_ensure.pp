# https://docs.puppet.com/puppet/latest/type.html#package-attribute-ensure
# ensure
#
# (Property: This attribute represents concrete state on the target system.)
#
# What state the package should be in. On packaging systems that can retrieve
# new packages on their own, you can choose which package to retrieve by
# specifying a version number or latest as the ensure value. On packaging
# systems that manage configuration files separately from
# rmaystem files, you can uninstall config files by specifying purged as the ensure value. This defaults to installed.
#
# Version numbers must match the full version to install, including release if
# the provider uses a release moniker. Ranges or semver patterns are not accepted
# except for the gem package provider. For example, to install the bash package
# from the rpm bash-4.1.2-29.el6.x86_64.rpm, use the string '4.1.2-29.el6'.
#
# Valid values are present (also called installed), absent, purged, held, latest. Values can match /./.
type Eit_types::Package_Ensure = Enum['present', 'installed', 'absent', 'purged', 'held', 'latest']
