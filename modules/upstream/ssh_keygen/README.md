# puppet-ssh_keygen

[![License](https://img.shields.io/github/license/voxpupuli/puppet-ssh_keygen.svg)](https://github.com/voxpupuli/puppet-ssh_keygen/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/voxpupuli/puppet-ssh_keygen.svg?branch=master)](https://travis-ci.org/voxpupuli/puppet-ssh_keygen)
[![Code Coverage](https://coveralls.io/repos/github/voxpupuli/puppet-ssh_keygen/badge.svg?branch=master)](https://coveralls.io/github/voxpupuli/puppet-ssh_keygen)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/ssh_keygen.svg)](https://forge.puppetlabs.com/puppet/ssh_keygen)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/ssh_keygen.svg)](https://forge.puppetlabs.com/puppet/ssh_keygen)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/ssh_keygen.svg)](https://forge.puppetlabs.com/puppet/ssh_keygen)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/ssh_keygen.svg)](https://forge.puppetlabs.com/puppet/ssh_keygen)

#### Table of Contents

1. [Usage - Configuration options and additional functionality](#usage)
2. [Development - Guide for contributing to the module](#development)

# Usage

Generate ssh keys for any user using ssh_keygen, that needs exist before using the module
```puppet
ssh_keygen { 'john': }
```

or if not using the default `/home/john`
```puppet
ssh_keygen { 'john':
  home => '/var/home'
}
```

the key comment can also be overriden with
```puppet
ssh_keygen { 'john':
  comment => 'john key'
}
```

Generate a dsa key
```puppet
ssh_keygen { 'john':
  type => 'dsa'
}
```

specify the bit length
```puppet
ssh_keygen { 'john':
  bits => '4096'
}
```

Generate new host key
```puppet
ssh_keygen { 'root':
  filename => '/etc/ssh/ssh_host_rsa_key'
}
```

## Development

This module is maintained by [Vox Pupuli](https://voxpupuli.org/). Voxpupuli
welcomes new contributions to this module, especially those that include
documentation and rspec tests. We are happy to provide guidance if necessary.

Please see [CONTRIBUTING](.github/CONTRIBUTING.md) for more details.

### Authors

* Carlos Sanchez <csanchez@maestrodev.com>
* Voxpupuli Team
