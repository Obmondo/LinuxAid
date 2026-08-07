# @summary Class for managing common::system::utility::bash
#
class common::system::utility::bash () {
  file {
    default:
      ensure => 'file',
      ;
    '/opt/obmondo/share/bash':
      ensure => 'directory',
      ;
    '/opt/obmondo/share/bash/bashrc':
      source  => 'puppet:///modules/common/system/utility/bash/bashrc',
      require => File['/opt/obmondo/share/bash'],
      ;
    '/etc/profile.d/obmondo.sh':
      source  => 'puppet:///modules/common/system/utility/bash/obmondo_profile',
      ;
    # the default root bashrc on many systems set PS1; we'd rather have our own
    # so let's just delete it
    '/root/.bashrc':
      ensure => 'absent',
  }
}
