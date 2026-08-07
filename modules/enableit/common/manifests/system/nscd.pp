# @summary Class for managing NSCD setup, caching DNS daemon, locally on client
#
class common::system::nscd () {
  contain profile::system::nscd
}
