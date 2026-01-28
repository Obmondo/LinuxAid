# @summary Class for common utilities
#
class common::system::utility () {
  contain ::common::system::utility::bash
  contain ::common::system::utility::tmux
  contain ::common::system::utility::atop
}

