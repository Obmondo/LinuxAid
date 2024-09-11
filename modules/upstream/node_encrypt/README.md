# `node_encrypt`: over the wire encryption.

1. [Overview](#overview)
1. [Usage](#usage)
1. [Ecosystem](#ecosystem)

## Overview

Do you wish your Puppet catalogs didn't contain plain text secrets? Are you tired
of limiting access to your Puppet reports because of the passwords clearly
visible in the change events?

This module will encrypt values for each node specifically, using their own
certificates. This means that not only do you not have plain text secrets, but
each node can decrypt only its own secrets.

<img src="assets/puppet6.png" alt="Puppet 6 logo" align="right" width="125" height="125">

What precisely does that mean? A resource that looks like the examples below will
never have your secrets exposed in the catalog, in any reports, or any other
cached state files. Any parameter of any resource type may be encrypted  by
simply annotating your secret string with a function call. **This relies on
Deferred execution functions in Puppet 6**. If you're running Puppet 5 or
below, then see the [legacy section below](#legacy-puppet-5-and-below-support)
for backwards compatibility.

```Puppet
user { 'erwin':
  ensure   => present,
  password => '{vT6YcbBhX.LL6s8'.node_encrypt::secret
}

file { '/etc/secretfile.cfg':
  ensure  => file,
  content => 'this string will be encrypted in your catalog'.node_encrypt::secret
}

file { '/etc/another_secretfile.cfg':
  ensure  => file,
  content => template('path/to/template.erb').node_encrypt::secret,
}

$token = lookup('application_token')
exec { 'authenticate service':
  command => '/bin/application-register ${token}'.node_encrypt::secret,
}
```

This also comes with a Puppet Face which can be used to encrypt content for a node
and then decrypt it on that node. If you like, you may also paste the ciphertext
into your manifest or Hiera datafiles and then manually invoke the `node_decrypt()`
function as needed.


## Usage

* `node_encrypt::secret()`
    * On Puppet6 or above, this is likely the only use you'll need to know.
    * This function encrypts a string on the master, and then decrypts it on the
      agent during catalog application.
    * Example: `'secret string'.node_encrypt::secret`
* `redact()`
    * This Puppet function allows you to remove from the catalog the value of a
      parameter that a class was called with.
        * The name of the parameter to redact.
        * The message to replace the parameter's value with. (optional)
* `puppet node encrypt`
    * This is a Puppet Face that generates encrypted ciphertext on the command line.
    * `puppet node encrypt -t testhost.example.com "encrypt some text"`
* `puppet node decrypt`
    * This is a Puppet Face that decrypts ciphertext on the command line. It is
      useful in command-line scripts, or in `exec` statements.
* `node_decrypt()`
    * This is a Puppet function used to decrypt encrypted text on the agent.
      You'll only need to use this if you save encrypted content in your manifests
      or Hiera data files.
    * Example: `content => Deferred("node_decrypt", [$encrypted_content])`
* `node_encrypt::certificates`
    * This class will synchronize certificates to all compile masters.
    * Generally not needed, unless the `clientcert_pem` fact fails for some reason.
* `node_encrypt::file`
    * Legacy type for Puppet 5 and below.
    * This is a defined type that wraps a standard file resource, but allows you
      to encrypt the content in the catalog and reports.

The simplest usage is like the example shown in the [Overview](#overview). This
defined type accepts most of the standard file parameters and simply encrypts the
file contents in the catalog.


### Function usage:

#### `node_decrypt($string)`

This function simply decrypts the ciphertext passed to it using the agent's own
certificate. It is generally only useful as a Deferred function on Puppet 6+.

```Puppet
$encrypted = lookup('encrypted_foo')
file { '/etc/something/or/other.conf:
  ensure  => file,
  owner   => 'root',
  group   => 'root',
  mode    => '0600',
  content => Deferred("node_decrypt", [$encrypted]),
}
```


#### `redact($parameter, $replacewith)`

This function will modify the catalog during compilation to remove the named
parameter from the class from which it was called. For example, if you wrote a
class named `foo` and called `redact('bar')` from within that class, then the
catalog would not record the value of `bar` that `foo` was called with.

```Puppet
class foo($bar) {
  # this call will display the proper output, but because it's not a resource
  # the string won't exist in the catalog.
  notice("Class['foo'] was called with param ${bar}")

  # but the catalog won't record what the passed in param was.
  redact('bar')
}

class { 'foo':
  bar => 'this will not appear in the catalog',
}
```

**Warning**: If you use that parameter to declare other classes or resources,
then you must take further action to remove the parameter from those declarations!

This takes an optional second parameter of the value to replace the original
parameter declaration with. This parameter is required if the class declares
a type that is not `String` for the parameter you're redacting.


### Using the command line decryption tool

This comes with a Puppet Face that can encrypt or decrypt on the command line.
You can use this in your own scripts via several methods. The ciphertext can be
generated on the CA or any compile master using the `puppet node encrypt`
command.

    # puppet node encrypt -t testhost.puppetlabs.vm "encrypt some text"
    -----BEGIN PKCS7-----
    MIIMqwYJKoZIhvcNAQcDoIIMnDCCDJgCAQAxggJ7MIICdwIBADBfMFoxWDBWBgNV
    BAMMT1B1cHBldCBDQSBnZW5lcmF0ZWQgb24gcHVwcGV0ZmFjdG9yeS5wdXBwZXRs
    [...]
    MbxinAGtO0eF4i8ova9MJykDPe600IY2b9ZY4mIskDqvHS9bVoK4fJGuRWAXiVBY
    bFaZ36l90LkyLLrrSfjah/Tdqd8cHrphofsWVFWBmM1uErX1jBuuzngIehm40pN7
    ClVbGy9Ow3zado1spWfDwekLoiU5imk77J9POy0X8w==
    -----END PKCS7-----

Decrypting on the agent is just as easy, though a bit more flexible. For
convenience in these examples, let's assume that we've set a variable like such:

    # export SECRET=$(puppet node encrypt -t testhost.puppetlabs.vm "your mother was a hamster")

You can then decrypt this data by:

* Passing data directly using the `--data` option:
    * `puppet node decrypt --data "${SECRET}"`
    * On some platforms, this may exceed command length limits!
* Setting data in an environment variable and passing the name:
    * `puppet node decrypt --env SECRET`
* Piping data to STDIN:
    * `echo "${SECRET}" | puppet node decrypt`
    * `cat /file/with/encrypted/blob.txt | puppet node decrypt`


### Automatically distributing certificates to compile masters

The agent should send its public certificate as a custom `clientcert_pem` fact,
making this a seamless zero-config process. In the case that doesn't work, you
can distribute certificates to your compile masters using the
`node_encrypt::certificates` class so that encryption works from all compile
masters. Please be aware that **this class will create a fileserver mount on the
CA node** making public certificates available for download by all nodes.

Classify all your masters, including the CA or Master of Masters, with this class.
This will ensure that all masters have all agents' public certificates.

**Note**:<br />
If this is applied to all nodes in your infrastructure then all agents will have all
public certificates synched. This is not a security risk, as public certificates are
designed to be shared widely, but it is something you should be aware of. If you wish
to prevent that, just make sure to classify only your masters.

Parameters:

* [*ca_server*]
    * If the CA autodetection fails, then you can specify the $fqdn of the CA server here.

* [*legacy*]
    * Set to `true` if you're still using legacy `auth.conf` on Puppet 5.

* [*sort_order*]
    * If you've customized your HOCON-based `auth.conf`, set the appropriate sort
      order here. The default rule's weight is 500, so this parameter defaults to
      `300` to ensure that it overrides the default.


### Legacy Puppet 5 and below support

<img src="assets/puppet5.png" alt="Puppet 5 logo" align="right" width="125" height="125">

Deferred functions were introduced in Puppet 6. In prior versions, `node_encrypt`
required a custom provider for each resource type it supported. As such, we could
only encrypt files, using a defined type wrapper like so:

```Puppet
node_encrypt::file { '/tmp/foo':
  owner   => 'root',
  group   => 'root',
  mode    => '0600',
  content => 'This string will never appear in the catalog.',
}
```

If you'd like to pre-encrypt your data, you can pass it as the `encrypted_content`
instead. The ciphertext can be stored directly in your manifest file, in Hiera,
or anywhere else you'd like. Note that if you choose to do this, the ciphertext
must be encrypted specifically for each node. You cannot share secrets amongst nodes.

```Puppet
node_encrypt::file { '/tmp/foo':
  owner             => 'root',
  group             => 'root',
  encrypted_content => hiera('encrypted_foo'),
}
```

The CLI tool can be useful when running `exec resources` with embedded secrets.
Note the careful use of single quotes to prevent variable expansion in Puppet:

```Puppet
exec { 'set service passphrase':
  command     => 'some-service --set-passphrase="$(puppet node decrypt --env SECRET)"',
  path        => '/opt/puppetlabs/bin:/usr/bin',
  environment => "SECRET=${node_encrypt('and your father smelt of elderberries')}",
}
```


#### Deprecated Parameters

Since public certificates are designed to be shared widely without a security
risk, we made the decision to simplify and no longer manage a whitelist of
compile masters allowed to access the `public_certificates` mountpoint. If you
would like to enforce a whitelist anyway, then you can use one of the following
methods:

If you're using the legacy `auth.conf` format then you'll need to configure it
manually by editing `$confdir/auth.conf` on the CA server. Ensure that this
stanza comes before the existing `^/puppet/v3/file` rule and set the `whitelist`
parameter to `false` in your classification to disable the error.

```
# Node_encrypt: Allow limited access to the 'public_certificates' mountpoint:
path ~ ^/puppet/v3/file_(metadata|content)s?/public_certificates
auth yes
allow list,of,whitelisted,certnames
```

If you're using the modern HOCON based `auth.conf` format, then you can manage
access using a Puppet resource such as the following. Ensure that the `sort_order`
is lower than `300`, or the value you passed to `node_encrypt::certificates`.

```Puppet
puppet_authorization::rule { 'public certificates mountpoint override':
  match_request_path   => '^/puppet/v3/file_(metadata|content)s?/public_certificates',
  match_request_type   => 'regex',
  match_request_method => 'get',
  allow                => ['array', 'of', 'whitelisted', 'certnames'],
  sort_order           => 250,
  path                 => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
}
```


### Using on masterless infrastructures

For the most part, `node_encrypt` doesn't have as much value in a masterless
setup. When the agent is compiling its own catalog, there's no cached catalog or
network transfer. Nevertheless, there are use cases for it. For example, if you
have a report server configured, or are submitting catalogs & reports to PuppetDB,
you likely want to keep secrets hidden.

`node_encrypt` won't work out of the box on a masterless node because it relies
on the existence of the CA certificates. But it's easy to generate these
certificates so that it will work. Keep in mind that without the full CA
infrastructure, no other node will be able to decrypt these secrets.

```
$ rm -rf $(puppet master --configprint ssldir)/*
$ puppet cert list -a
$ puppet cert --generate ${puppet master --configprint certname} --dns_alt_names "$(puppet master --configprint dns_alt_names)"
```


## Ecosystem

#### How is this different from the new `Sensitive` type?

As of Puppet 4.6, [the core language supports a `Sensitive` type](https://puppet.com/docs/puppet/5.3/lang_data_sensitive.html).
This type marks data with a flag that prevents the components of the Puppet and
Puppet Enterprise stack from inadvertently displaying the value. For example, a
string that's marked as `Sensitive` will not display in reports or in the PE
Console.

*Unfortunately, it still exists as plain text in the catalog.* The `node_encrypt`
module encrypts data before it goes into the catalog, and it's only decrypted as
it's being written to disk.


#### What about [Hiera eyaml](https://github.com/TomPoulton/hiera-eyaml)?

Does this project replace that tool?

Not at all. They exist in different problem spaces.  Hiera eyaml is intended to
protect your secrets on-disk and in your repository.  With Hiera eyaml, you can
add secrets to your codebase without having to secure the entire codebase.
Having access to the code doesn't mean having access to the secrets in that code.

But the secrets are still exposed in the catalog and in reports. This means you
should be protecting them as well. `node_encrypt` addresses that problem. The two
projects happily coexist. You can (and should) use `eyaml` to store your secrets
on disk, while you use `node_encrypt` to protect the rest of the pipeline.

#### Integration with other tools

This was designed to make it easy to integrate support into other tooling. For
example, [this pull request](https://github.com/richardc/puppet-datacat/pull/17/files)
adds transparent encryption support to _rc's popular `datacat` module.


## Disclaimer

I take no liability for the use of this module. As this uses standard Ruby and
OpenSSL libraries, it should work anywhere Puppet itself does. I have not yet
validated on anything other than CentOS, though.

Contact
-------

binford2k@gmail.com

