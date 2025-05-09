# `node_encrypt`: over the wire encryption.

1. [Overview](#overview)
1. [Usage](#usage)
1. [Ecosystem](#ecosystem)
1. [License](#license)

## Overview

Do you wish your Puppet catalogs didn't contain plain text secrets? Are you
tired of limiting access to your Puppet reports because of the passwords clearly
visible in the change events? This module will encrypt values for each node
specifically, using their own certificates. This means that not only do you not
have plain text secrets in the catalog file, but each node can decrypt only its
own secrets.

<img src="assets/puppet6.png" alt="Puppet 6 logo" align="right" width="125" height="125">

What precisely does that mean? A resource that looks like the examples below will
never have your secrets exposed in the catalog, in any reports, or any other
cached state files. Any parameter of any resource type may be encrypted  by
simply annotating your secret string with a function call. **This relies on
Deferred execution functions in Puppet 6**. If you're running Puppet 5 or
below, then pin this module to `v0.4.1` or older for backwards compatibility.

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

## Suitability

Please note that `node_encrypt` is ***not a security panacea***. It will encrypt
your secrets in the catalog file on disk using the node's certificate, but the
corresponding private key is also on disk in clear text. This means that if an
attacker gains root level access to your filesystem, then they can likely read
both the encrypted secrets and the key required to decrypt them.

| ⚠️ **Warning:** |
|-----------------|
| *`node_encrypt` will only protect you in cases where an attacker has access to the catalog file, but not to the node's private certificate.* |

Some of the cases protected by `node_encrypt` might include:

* Using the catalog files for certain kinds of [impact analysis](https://dev.to/camptocamp-ops/automated-puppet-impact-analysis-1c1)
* Making catalogs available for troubleshooting with catalog diff
* Integrations that retrieve catalogs from [PuppetDB via API](https://puppet.com/docs/puppetdb/latest/api/query/v4/catalogs.html)

If you have more stringent security requirements, we suggest integrating with a purpose
built secret server. See [docs](https://puppet.com/docs/puppet/latest/integrations_with_secret_stores.html) for more details.


## Usage

* `node_encrypt::secret()`
    * This function encrypts a string on the server, and then decrypts it on the
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
    * This is a Puppet Face that decrypts ciphertext on the command line. It can
      be useful in command-line scripts.
* `node_decrypt()`
    * This is a Puppet function used to decrypt encrypted text on the agent.
      You'll only need to use this if you save encrypted content in your manifests
      or Hiera data files.
    * Example: `content => Deferred("node_decrypt", [$encrypted_content])`
* `node_encrypt::certificates`
    * This class will synchronize certificates to all compile servers.
    * Generally not needed, unless the `clientcert_pem` fact fails for some reason.

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
generated on the CA or any compile server using the `puppet node encrypt`
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


### Automatically distributing certificates to compile servers

The agent should send its public certificate as a custom `clientcert_pem` fact,
making this a seamless zero-config process. In the case that doesn't work, you
can distribute certificates to your compile servers using the
`node_encrypt::certificates` class so that encryption works from all compile
servers. Please be aware that **this class will create a fileserver mount on the
CA node** making public certificates available for download by all nodes.

Classify all your servers, including the CA or Primary Server, with this class.
This will ensure that all server have all agents' public certificates.

**Note**:<br />
If this is applied to all nodes in your infrastructure then all agents will have all
public certificates synched. This is not a security risk, as public certificates are
designed to be shared widely, but it is something you should be aware of. If you wish
to prevent that, just make sure to classify only your servers.

Parameters:

* [*ca_server*]
    * If the CA autodetection fails, then you can specify the $fqdn of the CA server here.

* [*sort_order*]
    * If you've customized your HOCON-based `auth.conf`, set the appropriate sort
      order here. The default rule's weight is 500, so this parameter defaults to
      `300` to ensure that it overrides the default.


### Using on serverless infrastructures

For the most part, `node_encrypt` doesn't have as much value in a serverless
setup. When the agent is compiling its own catalog, there's no cached catalog or
network transfer. Nevertheless, there are use cases for it. For example, if you
have a report server configured, or are submitting catalogs & reports to PuppetDB,
you likely want to keep secrets hidden.

`node_encrypt` won't work out of the box on a serverless node because it relies
on the existence of the CA certificates. But it's easy to generate these
certificates so that it will work. Keep in mind that without the full CA
infrastructure, no other node will be able to decrypt these secrets.

Note that this functionality was moved to the `puppetserver` application
in Puppet 6.x, so you'll need Puppet 5.x to generate this certificate.

```
$ rm -rf $(puppet config print ssldir --section server)/*
$ puppet cert list -a
$ puppet cert --generate ${puppet config print certname} --dns_alt_names "$(puppet config print dns_alt_names)"
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

#### Testing with [Onceover](https://github.com/dylanratcliffe/onceover)

If you use Onceover to test your puppet roles, you'll experience compilation failures
when using this module as it won't be able to find the private keys it expects.

```
Evaluation Error: Error while evaluating a Resource Statement, Evaluation Error: Error while evaluating a Function Call, Not a directory @ rb_sysopen - /dev/null/ssl/private_keys/example.com.pem
```

In your onceover.yaml file, mock the `node_encrypt` function as follows.

```yaml
functions:
  node_encrypt:
    returns: '-----BEGIN PKCS7----- MOCKED_DATA'
```



## Limitations

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-node_encrypt/blob/main/metadata.json)

## License

This codebase is licensed under the Apache2.0 licensing, however due to the nature of the codebase the open source dependencies may also use a combination of [AGPL](https://opensource.org/license/agpl-v3/), [BSD-2](https://opensource.org/license/bsd-2-clause/), [BSD-3](https://opensource.org/license/bsd-3-clause/), [GPL2.0](https://opensource.org/license/gpl-2-0/), [LGPL](https://opensource.org/license/lgpl-3-0/), [MIT](https://opensource.org/license/mit/) and [MPL](https://opensource.org/license/mpl-2-0/) Licensing.

## Disclaimer

I take no liability for the use of this module. As this uses standard Ruby and
OpenSSL libraries, it should work anywhere Puppet itself does. I have not yet
validated on anything other than CentOS, though.

## Authors

This module is a continuation of [binford2k/node_encrypt](https://forge.puppet.com/modules/binford2k/node_encrypt/readme) which was developed by [Ben Ford](https://github.com/binford2k). Thank you to all of our contributors.