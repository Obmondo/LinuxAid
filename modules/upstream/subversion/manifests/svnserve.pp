# Copyright (c) 2008, Luke Kanies, luke@madstop.com
# forked by Puzzle ITC
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Serve subversion-based code from a local location.  The job of this
# module is to check the data out from subversion and keep it up to
# date, especially useful for providing data to your Puppet server.
#
# Example usage:
#   subversion::svnserve { dist:
#       source => "https://reductivelabs.com/svn",
#       path => "/dist",
#       user => "puppet",
#       password => "mypassword"
#   }
define subversion::svnserve(
  $source,
  $path,
  $user = false,
  $password = false,
) {

  file { $path:
    ensure => directory,
    owner  => root,
    group  => root,
  }

  $svncmd = $user ? {
    false   => "/usr/bin/svn co --non-interactive ${source}/${name} .",
    default => "/usr/bin/svn co --non-interactive --username ${user} --password '${password}' ${source}/${name} .",
  }

  exec { "svnco-${name}":
    command => $svncmd,
    cwd     => $path,
    require => [ File[$path], Package['subversion'] ],
    creates => "${path}/.svn",
  }

  exec { "svnupdate-${name}":
    command => '/usr/bin/svn update',
    require => [ Exec["svnco-${name}"], Package['subversion'] ],
    onlyif  => '/usr/bin/svn status -u --non-interactive | /bin/grep "\*"',
    cwd     => $path,
  }
}
