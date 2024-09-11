# Changelog

All notable changes to this project will be documented in this file.

## Release 3.5.2

### Summary

- Extended test suite to puppet 5 and puppet 6
- Updated README.md and metadata.json
- Added .sync.yml for `pdk update`

## Release 3.5.1

**Features**
- Add automated static validations by github actions
- Add automated unit testing by github actions
- Converted to PDK (Puppet Development Kit)

**Bugfixes**

**Known Issues**

## Release 2.3.1
  Fixed issue with strict variables
## Release 2.3.0
  upport SSL certificate path and expose auth parameters at a global level (Greg Swift)
## Release 2.2.0
  Rename evenup-curator to jlambert121-curator
  Add support for curator jobs in hiera (Petter Abrahamsson)
  Add apt/yum repo management & additional ES connection params (Petter Abrahamsson)
  Add use_ssl and http_auth arguments. (Dan Sajner)
## Release 2.1.2
  Fixed remove parameter in alias (zyronix)
  Send cron stdout to /dev/null (mjs510)
## Release 2.1.1
  Correct inline_templates
  Correct timestring (SteveDevOps)
## Release 2.1.0
  Correct logfile parameter location (SteveDevOps)
  Support repository flag on delete
## Release 2.0.1
  Correct some command strings
  Ensure timestring is included
## Release 2.0.0
  Updated for curator >= 3.0.0
  Reworked job defined type - no longer supports multiple jobs
  Acceptance tests
## Release 1.1.0
  Added support for --timestring parameter (bflad)
  Added snapshot_recent, snapshot_delete_order (phononet)
  Remove single letter args support - removed curator 2.0.2 (phononet)
  Add support for multiple commands, master-only (bodgit)
  Remove separator option - removed curator 1.2.0 (dspangen)
## Release 1.0.1
  Fix ordering for command options
## Release 1.0.0
  Update for curator >= 1.1.0
## Release 0.0.1
  Initial release