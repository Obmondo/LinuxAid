# Security Policy

## Reporting a Vulnerability

Please **do not** open a public GitHub issue for security vulnerabilities.

Report it privately via
[GitHub Security Advisories](https://github.com/Obmondo/LinuxAid/security/advisories/new)
for this repository. A LinuxAid maintainer will acknowledge the report within
five working days, work with you to understand and validate the impact, and
coordinate a fix and disclosure timeline before any public advisory goes out.

If you'd rather not use GitHub, you can also report security issues directly
to [info@obmondo.com](mailto:info@obmondo.com).

When reporting, please include the affected role, module or script, the
LinuxAid release or commit you tested against, and steps to reproduce. Do
not include secrets, certificates or customer data in the report.

## Supported Versions

LinuxAid is developed on the `master` branch and published as tagged releases
(see [CHANGELOG.md](CHANGELOG.md)). Security fixes land on `master` and are
included in the next tagged release; there are no long-term-support branches
and fixes are not backported to older tags. Please update to the latest
release before reporting an issue that may already be fixed.

## Scope

This policy covers the contents of this repository: the environment manifests
in `manifests/`, the first-party modules in `modules/enableit/`, the node
classifier and autosign scripts (`puppet_enc.rb`, `puppet_autosign.rb`,
`linuxaid_enc.rb`), the Hiera configuration, and the helper scripts in `bin/`.

Modules under `modules/upstream/` are third-party Puppet modules vendored via
the `Puppetfile`. Vulnerabilities in those should be reported to the upstream
project, but please tell us as well so we can update the vendored copy.
Vulnerabilities in the operating system packages and services that LinuxAid
installs and configures should be reported to the respective project or
distribution.

## Disclosure

Once a fix is available we publish a GitHub Security Advisory for this
repository describing the issue, the affected releases and the fixed release.
We credit reporters in the advisory unless they ask us not to.
