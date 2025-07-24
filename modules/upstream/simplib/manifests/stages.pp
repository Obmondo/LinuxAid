# @summary Expands on the `puppetlabs-stdlib` stages
#
# Adds additional intermediate stages that we found necessary when developing
# various SIMP modules that had global ramifications.
#
# Primarily, we wanted to ensure that anyone using the stdlib stages was not
# tripped up by any of our modules that may enable, or disable, various system,
# components; particularly ones that require a reboot.
#
# Added Stages:
#
#   * ``simp_prep`` -> Comes before stdlib's ``setup``
#   * ``simp_finalize`` -> Comes after stdlib's ``deploy``
#
class simplib::stages {
  include stdlib::stages

  stage { 'simp_prep': before      => Stage['setup'] }
  stage { 'simp_finalize': require => Stage['deploy'] }
}
