# @summary Class for managing common::system::utility::tmux
#
class common::system::utility::tmux () {

  package::install('tmux')

  file {
    default:
    ensure => 'file',
      ;

    '/etc/tmux.conf':
      ensure => 'file',
      source => 'puppet:///modules/common/system/utility/tmux/tmux.conf',
      ;

    '/opt/obmondo/share/tmux':
      ensure => 'directory',
      ;

    '/opt/obmondo/share/tmux/badges.sh':
      source  => 'puppet:///modules/common/system/utility/tmux/badges.sh',
      mode    => 'a+x',
      require => File['/opt/obmondo/share/tmux'],
      ;

    '/opt/obmondo/share/tmux/tmux-env.sh':
    content => epp('common/system/utility/tmux/tmux-env.sh.epp'),
    mode    => 'a+x',
    require => File['/opt/obmondo/share/tmux'],
      ;
  }
}
