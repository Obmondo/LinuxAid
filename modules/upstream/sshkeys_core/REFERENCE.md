# Reference

## Resource types
* [`ssh_authorized_key`](#ssh_authorized_key): Manages SSH authorized keys. Currently only type 2 keys are supported.  In their native habitat, SSH keys usually appear as a single long lin
* [`sshkey`](#sshkey): Installs and manages ssh host keys.  By default, this type will install keys into `/etc/ssh/ssh_known_hosts`. To manage ssh keys in a differe
## Resource types

### ssh_authorized_key

Manages SSH authorized keys. Currently only type 2 keys are supported.

In their native habitat, SSH keys usually appear as a single long line, in
the format `<TYPE> <KEY> <NAME/COMMENT>`. This resource type requires you
to split that line into several attributes. Thus, a key that appears in
your `~/.ssh/id_rsa.pub` file like this...

    ssh-rsa AAAAB3Nza[...]qXfdaQ== nick@magpie.example.com

...would translate to the following resource:

    ssh_authorized_key { 'nick@magpie.example.com':
      ensure => present,
      user   => 'nick',
      type   => 'ssh-rsa',
      key    => 'AAAAB3Nza[...]qXfdaQ==',
    }

To ensure that only the currently approved keys are present, you can purge
unmanaged SSH keys on a per-user basis. Do this with the `user` resource
type's `purge_ssh_keys` attribute:

    user { 'nick':
      ensure         => present,
      purge_ssh_keys => true,
    }

This will remove any keys in `~/.ssh/authorized_keys` that aren't being
managed with `ssh_authorized_key` resources. See the documentation of the
`user` type for more details.

**Autorequires:** If Puppet is managing the user account in which this
SSH key should be installed, the `ssh_authorized_key` resource will autorequire
that user.


#### Properties

The following properties are available in the `ssh_authorized_key` type.

##### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

##### `type`

Valid values: ssh-dss, ssh-rsa, ecdsa-sha2-nistp256, ecdsa-sha2-nistp384, ecdsa-sha2-nistp521, ssh-ed25519, dsa, ed25519, rsa

Aliases: "dsa"=>"ssh-dss", "ed25519"=>"ssh-ed25519", "rsa"=>"ssh-rsa"

The encryption type used.

##### `key`

The public key itself; generally a long string of hex characters. The `key`
attribute may not contain whitespace.

Make sure to omit the following in this attribute (and specify them in
other attributes):

* Key headers, such as 'ssh-rsa' --- put these in the `type` attribute.
* Key identifiers / comments, such as 'joe@joescomputer.local' --- put these in
  the `name` attribute/resource title.

##### `user`

The user account in which the SSH key should be installed. The resource
will autorequire this user if it is being managed as a `user` resource.

##### `target`

The absolute filename in which to store the SSH key. This
property is optional and should be used only in cases where keys
are stored in a non-standard location, for instance when not in
`~user/.ssh/authorized_keys`. The parent directory must be present
if the target is in a privileged path.

Default value: absent

##### `options`

Key options; see sshd(8) for possible values. Multiple values
should be specified as an array. For example, you could use the
following to install a SSH CA that allows someone with the
'superuser' principal to log in as root

    ssh_authorized_key { 'Company SSH CA':
      ensure  => present,
      user    => 'root',
      type    => 'ssh-ed25519',
      key     => 'AAAAC3NzaC[...]CeA5kG',
      options => [ 'cert-authority', 'principals="superuser"' ],
    }

#### Parameters

The following parameters are available in the `ssh_authorized_key` type.

##### `name`

namevar

The SSH key comment. This can be anything, and doesn't need to match
the original comment from the `.pub` file.

Due to internal limitations, this must be unique across all user accounts;
if you want to specify one key for multiple users, you must use a different
comment for each instance.

##### `drop_privileges`

Whether to drop privileges when writing the key file. This is
useful for creating files in paths not writable by the target user. Note
the possible security implications of managing file ownership and
permissions as a privileged user.

Default value: `true`

### sshkey

Installs and manages ssh host keys.  By default, this type will
install keys into `/etc/ssh/ssh_known_hosts`. To manage ssh keys in a
different `known_hosts` file, such as a user's personal `known_hosts`,
pass its path to the `target` parameter. See the `ssh_authorized_key`
type to manage authorized keys.


#### Properties

The following properties are available in the `sshkey` type.

##### `ensure`

Valid values: present, absent

The basic property that the resource should be in.

Default value: present

##### `type`

Valid values: ssh-dss, ssh-ed25519, ssh-rsa, ecdsa-sha2-nistp256, ecdsa-sha2-nistp384, ecdsa-sha2-nistp521, dsa, ed25519, rsa

Aliases: "dsa"=>"ssh-dss", "ed25519"=>"ssh-ed25519", "rsa"=>"ssh-rsa"

The encryption type used.  Probably ssh-dss or ssh-rsa.

##### `key`

The key itself; generally a long string of uuencoded characters. The `key`
attribute may not contain whitespace.

Make sure to omit the following in this attribute (and specify them in
other attributes):

* Key headers, such as 'ssh-rsa' --- put these in the `type` attribute.
* Key identifiers / comments, such as 'joescomputer.local' --- put these in
  the `name` attribute/resource title.

##### `host_aliases`

Any aliases the host might have.  Multiple values must be
specified as an array.

##### `target`

The file in which to store the ssh key.  Only used by
the `parsed` provider.

#### Parameters

The following parameters are available in the `sshkey` type.

##### `name`

namevar

The host name that the key is associated with.


