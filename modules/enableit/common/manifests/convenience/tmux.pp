# @summary Class for managing common::convenience::tmux
#
# @param manage Boolean indicating whether to manage tmux package and files. Defaults to true.
#
# @param noop_value Optional Boolean for noop operations. Defaults to false.
#
class common::convenience::tmux (
  Boolean           $manage     = true,
  Optional[Boolean] $noop_value = false,
) {

  package::install('tmux')

  file {
    default:
    ensure => ensure_file($manage),
    noop   => $noop_value,
      ;

    '/etc/tmux.conf':
    ensure => ensure_file($manage),
      source => 'puppet:///modules/common/convenience/tmux/tmux.conf',
      ;

    '/opt/obmondo/share/tmux':
      ensure => ensure_dir($manage),
      ;

    '/opt/obmondo/share/tmux/badges.sh':
      source  => 'puppet:///modules/common/convenience/tmux/badges.sh',
      mode    => 'a+x',
    require => File['/opt/obmondo/share/tmux'],
      ;

    '/opt/obmondo/share/tmux/tmux-env.sh':
    content => epp('common/convenience/tmux/tmux-env.sh.epp'),
    mode    => 'a+x',
    require => File['/opt/obmondo/share/tmux'],
      ;
  }
}
