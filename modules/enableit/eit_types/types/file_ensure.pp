# ensure
#
# (Property: This attribute represents concrete state on the target system.)
#
# Whether the file should exist, and if so what kind of file it should be. Possible values are present, absent, file, directory, and link.
#
# present accepts any form of file existence, and creates a normal file if the file
# is missing. (The file will have no content unless the content or source attribute is used.)
# absent ensures the file doesn
# st, and deletes it if necessary.
# file ensures i a normal file, and enables use of the content or source attribute.
# directory ensures i a directory, and enables use of the source, recurse, recurselimit, ignore, and purge attributes.
# link ensures the file is a symlink, and requires that you also set the target attribute.
# Symlinks are supported on all Posix systems and on Windows Vista / 2008 and higher.
# On Windows, managing symlinks requires Puppet agen user account to have theete Symbolic
# Linksan be configured in theer Rights Assignmenection in the Windows policy editor.
# By default, Puppet agent runs as the Administrator account, which has this privilege.

# Puppet avoids destroying directories unless the force attribute is set to true.
# This means that if a file is currently a directory, setting ensure to anything
# but directory or present will cause Puppet to skip managing the resource and log either a notice or an error.
#
# There is one other non-standard value for ensure. If you specify the path to another
# file as the ensure value, it is equivalent to specifying link and using that path as the target:
#
# # Equivalent resources:
#
# file { '/etc/inetd.conf':
# ensure => '/etc/inet/inetd.conf',
# }
#
# file { '/etc/inetd.conf':
# ensure => link,
# target => '/etc/inet/inetd.conf',
# }
# However, we recommend using link and target explicitly, since this behavior can be harder to read and is deprecated as of Puppet 4.3.0.
#
# Valid values are absent (also called false), file, present, directory, link. Values can match /./.
type Eit_types::File_Ensure = Variant[Eit_types::Ensure, Enum['file','directory','link'], Boolean]

