## 1.0.1
### Summary
This is a minor release to formaly announce that this module is not supported. Any previous claims otherwise were are in error

#### Changed
- Readme changes made.

#### Removed
- All mentions of this module being supported were removed.

## Release [1.0.0]
### Summary
This is a major release that **drops Puppet 3 support**

#### Added
- `setting` and `path` as namevars for `hocon_setting` ([HC-30](https://tickets.puppet.com/browse/HC-30))
- support for localization ([MODULES-4528](https://tickets.puppet.com/browse/MODULES-4528))

#### Changed
- lower bound of Puppet support to 4.7.0

#### Fixed
- test failures
- specs to reflect new output format ([HC-98](https://tickets.puppet.com/browse/HC-98))

## Release [0.9.4]
### Summary
This is a bugfix release.

#### Fixed
* Confine provider based on hocon gem
* Handle changing value from scalar to array
* Handle adding array value when array doesn't exist

## Release [0.9.3]
### Summary
This is a feature release.

#### Changed
* Update the hocon gem dependency from 0.9.2 to 0.9.3

#### Added
* Add support for managing individual array elements via the `array_element`
  value for the `type` parameter

## Release [0.9.2]
### Summary
This is a minor bugfix release.

#### Fixed
* Move the logic for saving a modified configuration file out of its own
  separate class and into the provider. This resolves an issue wherein
  the hocon gem was sometimes being required when it shouldn't have been,
  leading to errors.

## Release [0.9.1]
### Summary
This is a minor bugfix release.

#### Fixed
* Allow true numeric values to be set in a configuration file in versions
  of Puppet prior to 4.0.0.

## Release [0.9.0]
### Summary
This is a major feature release.

* Update the hocon gem dependency to the newly released 0.9.0 version.
* puppetlabs-hocon will no longer change an existing configuration file's
  ordering, comments, or indentation when modifying or adding settings.
* Add support for passing arrays and hashes to the `value` parameter
* Add support for passing in the exact text of a setting as it is
  desired to appear in the configuration file under the `value`
  setting (useful, for example, if one wants to insert a substitution,
  or a value with internal comments, such as a map)

[1.0.0]: https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.4...1.0.0
[1.0.0]: https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.4...1.0.0
[0.9.4]: https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.3...0.9.4
[0.9.3]: https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.2...0.9.3
[0.9.2]: https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.1...0.9.2
[0.9.1]: https://github.com/puppetlabs/puppetlabs-hocon/compare/0.9.0...0.9.1
[0.9.0]: https://github.com/puppetlabs/puppetlabs-hocon/commits/0.9.0
