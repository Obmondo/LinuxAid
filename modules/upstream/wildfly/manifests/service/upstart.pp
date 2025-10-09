# Wildfly upstart configuration
#
class wildfly::service::upstart {
  # Use sysvinit scripts for upstart 
  include wildfly::service::sysvinit

}
