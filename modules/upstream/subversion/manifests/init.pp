#
# subversion module
#
# Copyright (c) 2008, Luke Kanies, luke@madstop.com
# forked by Puzzle ITC
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
# forked by Camptocamp SA
# Marc Fournier, marc.fournier(at)camptocamp.com
# Christian Kaenzig, christian.kaenzig(at)camptocamp.com
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
#


#
# == Class: subversion
#
# Installs subversion and configures the client to NOT store repository
# passwords in users home directories. This can still be overriden by editing
# ~/.subversion/config
#
# For more details, have a look at: http://svnbook.red-bean.com/nightly/en/svn.advanced.confarea.html#svn.advanced.confarea.opts.config
#
class subversion (
  $backupdir = $subversion::params::backupdir,
  $dir = $subversion::params::dir,
) inherits ::subversion::params {

  case $::osfamily {
    'Debian': { include ::subversion::debian }
    default: { include ::subversion::base }
  }
}

