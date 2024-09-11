The directory hosting the implementation of this puppet module is organized as follows:

```
.gitignore              # Git ignore file
.ruby-{version,gemset}  # [RVM](https://rvm.io/) configuration
.vagrant_init.rb        # Vagrant provisionner to test this module
├── Gemfile[.lock]      # [Bundler](http://bundler.io/) configuration
├── LICENSE             # Licence file
├── README.md           # This file
├── Rakefile            # Definition of the [rake](https://github.com/jimweirich/rake) tasks
├── Vagrantfile         # Pilot Vagrant to test this module
├── docs/               # [Read the Docs](readthedocs.org) main directory
├── files/              # (eventually) Contains static files, which managed nodes can download
├── lib/                # (eventually) Custom facts/type/provider definitions
├── manifests/
│   ├── init.pp         # Main manifests file which defines the class
│   ├── common/
│   │   ├── debian.pp   # Specific Debian setup for the main class
│   │   └── redhat.pp   # Specific Redhat setup for the main class
│   ├── common.pp       # Common class setup for all OS
│   ├── ...             # Implementation of the other slurm::* classes / definitions
│   └── params.pp       # Class parameters
├── metadata.json       # Puppet module configuration file -- See http://tinyurl.com/puppet-metadata-json
├── mkdocs.yml          # [Read the Docs](readthedocs.org) configuration
├── pkg/                # Hold build packages to be published on the [Puppet forge](https://forge.puppet.com/ULHPC/slurm)
├── spec/               # (eventually) [Rspec](https://www.relishapp.com/rspec/) tests
├── templates/          # (eventually) Module ERB template files
└── tests/              # Tests cases for the module usage
    ├── <topic>.pp      # Sample testing manifest
    └── vagrant/        # Place-holder for the vagrant deployment
        ├── config.yaml          # Custom vagrant config overwritting defaults (not versionned)
        ├── config.yaml.sample   # Sample example of the vagrant settings
        ├── puppet/              # Placeholder for vagrant puppet apply provisionning
        │   ├── hiera.yaml       # Hiera configuration
        │   ├── hieradata/       # Hiera datadir
        │   ├── modules/         # puppet modules required for this one
        │   └── site/            # puppet profiles
        ├── rpmbuild/            # cross-VM shared directory for built RPMs
        ├── scripts/             # provisioning scripts
        └── shared/              # cross-VM shared directory
```

Globally, this module follows the [official PuppetLabs guidelines for the predictable directory tree structure of Puppet modules](http://docs.puppetlabs.com/puppet/latest/reference/modules_fundamentals.html#module-layout).
