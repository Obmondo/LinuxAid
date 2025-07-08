# @summary Class for managing common::convenience::bash
#
# @param manage Whether to manage the files. Defaults to true.
#
# @param noop_value Whether to perform no-operation. Defaults to false.
#
class common::convenience::bash (
  Boolean           $manage     = true,
  Optional[Boolean] $noop_value = false,
) {
  file {
    default:
      ensure => ensure_file($manage),
      noop   => $noop_value,
      ;
    '/opt/obmondo/share/bash':
      ensure  => ensure_dir($manage),
      ;
    '/opt/obmondo/share/bash/bashrc':
      source  => 'puppet:///modules/common/convenience/bash/bashrc',
      require => File['/opt/obmondo/share/bash'],
      ;
    '/etc/profile.d/obmondo.sh':
      source  => 'puppet:///modules/common/convenience/bash/obmondo_profile',
      ;
    # the default root bashrc on many systems set PS1; we'd rather have our own
    # so let's just delete it
    '/root/.bashrc':
      ensure => 'absent',
  }
}
