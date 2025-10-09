#
# Executes an arbitrary JBoss-CLI command
#   `[node-type=node-name (/node-type=node-name)*] : operation-name ['('[name=value [, name=value]*]')'] [{header (;header)*}]`.
#   This define is a wrapper for `wildfly_cli` that defaults to your local Wildfly installation.
#
# @param command The actual command to execute.
# @param unless If this parameter is set, then this `cli` will only run if this command condition is met.
# @param onlyif If this parameter is set, then this `cli` will run unless this command condition is met.
define wildfly::cli(
  String $command = $title,
  Optional[String] $unless = undef,
  Optional[String] $onlyif = undef) {

  wildfly_cli { $title:
    command  => $command,
    username => $wildfly::mgmt_user['username'],
    password => $wildfly::mgmt_user['password'],
    host     => $wildfly::setup::properties['jboss.bind.address.management'],
    port     => $wildfly::setup::properties['jboss.management.http.port'],
    unless   => $unless,
    onlyif   => $onlyif,
    require  => Service['wildfly'],
  }

}
