### 2020-01-28 (3.1.0)
  * Add support for RHEL 8 and newer Fedora versions (robertc99)
  * Add missing dependency (Thodoris Sotiropoulos)

### 2019-02-24 (3.0.0)
  * While this is a major release, it is totally backward compatible and
      only deprecates EOL platforms and versions of Puppet.
  * Drop support for Puppet 4
  * Drop support for EOL platforms

### 2019-02-24 (2.13.1)
  * Add acceptance tests
  * Fix bug when setting service_ensure to 'stopped'
  * Fix ordering bug when using extra_packages

### 2019-02-07 (2.13.0)
  * Add support for running on 32bit Suse systems.

### 2019-01-15 (2.12.0)
  * Add ability to generate REFERENCE.md

### 2019-01-15 (2.11.0)
  * Add parameter `pam_mkhomedir_umask` to make the umask configurable
    for pam_mkhomedir

### 2019-01-14 (2.10.1)
  * Require `extra_packages` be installed before starting oddjobd

### 2019-01-07 (2.10.0)
  * Support Puppet 6 and stdlib 5

### 2018-05-21 (2.9.0)
  * Warn instead of failing on errors. This allows older, EOL platforms
    to be used while allowing us to not have to support them.
  * Test with ruby 2.4.3 when using Puppet 5

### 2018-05-15 (2.8.0)
  * Add support for Ubuntu 18.04 (@dnlsng)

### 2018-02-02 (2.7.0)
  * Add support for Fedora 27 (@dnaeon - Marin Atanasov Nikolov)

### 2018-01-13 (2.6.0)
  * Drop Support for Fedora 25 since it is end of life. (GH)

### 2018-01-13 (2.5.0)
  * Add support for Amazon Linux 2 (Eric Olsen and Garrett Honeycutt)

### 2017-12-27 (2.4.1)
  * Fix Hiera bug (John Strong)

### 2017-12-10 (2.4.0)
  * Add support for Gentoo (Garrett Honeycutt)

### 2017-11-13 (2.3.0)
  * Add support for Debian 9 (Garrett Honeycutt)

### 2017-11-13 (2.2.2)
  * Remove deprecated key from metadata (Garrett Honeycutt)

### 2017-11-10 (2.2.1)
  * Fixed bug that prevented Ubuntu systems from being recognized.
    (Garrett Honeycutt)

### 2017-10-31 (2.2.0)
  * Test all supported platforms!! (Phil Friderici)
  * Deprecate params pattern in favor of data in modules with Hiera 5 (Garrett Honeycutt)
  * Document with puppet-strings (Phil Friderici)
  * Remove sorted configuration as this is no longer needed for support ruby versions (Phil Friderici)

### 2017-09-14 (2.1.0)
  * Add support for Puppet 5 #46 (Garrett Honeycutt)
  * Add support for Suse 11.3, 11.4 and 12.x #45 (Ben Kevan)
  * Add support for Fedora 25 and 26 releases #44 (Marin Atanasov Nikolov)

### 2017-05-19 (2.0.0)
  * Updated Module to Puppet >= 4.X #40 (Dennis Pattmann)

### 2017-05-18 (1.0.1)
  * Messagebus fix #39 (Garrett Honeycutt)

### 2017-05-09 (1.0.0)
  * Release the module as v1.0.0 #38 (Garrett Honeycutt)
  * Setting ensure => 'absent' now further disables sssd #32 (Marc Chadwick)

### 2017-01-24 (0.4.1)
  * Fix service restart issue #30 (Gjermund Jensvoll)
  * Fix messagebus service related error #29 (Gjermund Jensvoll)

### 2016-11-12 (0.4.0)
  * Add support for Ruby 2.3.1 #27 (Garrett Honeycutt)
  * Add ensure_resources and ensure_packages to avoid collisions #26 (Daniel James Goulder)
  * Add sssd_package_ensure parameter #24 (Taylan Develioglu)

### 2016-08-24 (0.3.1)
  * Fix Service[oddjobd] failing to start #22 (Jeff McCune)
  * Fix newline under each section in sssd.conf #18 (Gjermund Jensvoll)

### 2016-02-01 (0.3.0)
  * Stop sorting config keys for newer ruby versions #13 (Brad Cowie)
  * Ensure sssd.conf consistency during first Puppet run #11 (Nemanja Delic)

### 2015-12-30 (0.2.1)
  * Update testing, linting and syntax suites #7 (Chris Edester)
  * RedHat 5 authconfig needs to be latest #7 (Chris Edester)
  * service_ensure option #6 (Robert Bruce)
  * Licence info #5 (Gjermund Jensvoll)

### 2015-07-21 (0.2.0)
  * RedHat 5 support #3 (Chris Edester)
  * Mkhomedir cmd #2 (Chris Edester)

### 2015-07-20 (0.1.4)
  * Anchor pattern, private class and spec tests #1 (Chris Edester)

### 2015-07-06 (0.1.3)
  * Added missing file pam_mkhomedir (Gjermund Jensvoll)

### 2015-07-06 (0.1.2)
  * Fixed metadata.json syntax errors (Gjermund Jensvoll)

### 2015-07-04 (0.1.1)
  * Added compatability data for Puppet forge (Gjermund Jensvoll)

### 2015-07-04 (0.1.0)
  * First release (Gjermund Jensvoll)
