# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-simplib` is SIMP's **core utility library**. It ships almost no
Puppet-language classes — its value is in its Ruby surface: **~56 Puppet
functions** (`lib/puppet/functions/`), **15 top-level custom data types** (`types/`, plus namespaced subtypes),
**33 custom facts** (`lib/facter/`), and **7 custom resource types with
providers** (`lib/puppet/type/` + `lib/puppet/provider/`). Nearly every other
SIMP module depends on it, so **it is a foundational dependency for the whole
SIMP fleet** — changes here ripple across the entire ecosystem, and backward
compatibility matters far more than in a leaf module.

The module's real API is not its manifests but:

- **`simplib::lookup`** — SIMP's Hiera-lookup wrapper. Unlike stock `lookup()`,
  it checks **global scope first** (a pre-declared class parameter or an ENC value) — but returns that value only when it is *truthy* (`return global_param if global_param`); a global `false`/`undef` falls through to the normal `lookup()` back-ends
  (`lib/puppet/functions/simplib/lookup.rb`). This is why SIMP modules route
  feature toggles through `simplib::lookup('simp_options::*', { 'default_value'
  => ... })` — the value resolves whether it was set via a declared class, an
  ENC, or Hiera.
- **The custom data types** (`Simplib::IP`, `Simplib::Host`, `Simplib::Port`,
  `Simplib::Netlist`, `Simplib::Domain`, the `Simplib::Syslog::*` /
  `Simplib::Libcrypt::*` / `Simplib::Cron::*` families, etc.) — used as
  parameter types throughout SIMP manifests.
- **The custom facts** (`fips_enabled`, `reboot_required`, `boot_dir_uuid`,
  `init_systems`, `cpuinfo`, the `simplib__*` namespaced facts, …) — consumed
  by SIMP modules to make host-specific decisions.

The three actual manifests (`simplib::reboot_notify`, `simplib::stages`,
`simplib::install`) are thin conveniences layered on top of that surface.

### Business logic

**Manifests (3 total).** None of them call `assert_private()`; all are public.

- **`simplib::reboot_notify` (`manifests/reboot_notify.pp`)** — Controller
  class for the `reboot_notify` custom type. Declares a single control resource
  `reboot_notify { '__simplib_control__': control_only => true }` and exposes one
  parameter, `$log_level` (`Simplib::PuppetLogLevel`, default `'notice'`), which
  sets the log level of the reboot messages. Set
  `simplib::reboot_notify::log_level: debug` in Hiera to silence the messages
  outside debug runs (`reboot_notify.pp`).
- **`simplib::stages` (`manifests/stages.pp`)** — `include stdlib::stages`,
  then adds two SIMP stages: `simp_prep` (`before => Stage['setup']`) and
  `simp_finalize` (`require => Stage['deploy']`). These bracket the stdlib run
  stages so SIMP changes with global ramifications (e.g. reboots) land at
  predictable points (`stages.pp`).
- **`simplib::install` (`manifests/install.pp`)** — Defined type that
  installs a `Hash` of packages via `ensure_packages`. Each hash key is a
  package name; its value is an optional per-package options hash merged over the
  `$defaults` hash (`install.pp`). `$defaults` defaults to
  `{ 'ensure' => 'present' }`. It is a **defined type rather than a function** so
  the resulting `Package` resources can be referenced in manifest ordering
  (`install.pp`).

**Functions (`lib/puppet/functions/`, ~56).** Grouped by purpose:

- **Lookup** — `simplib::lookup` (the flagship, described above);
  `simplib::dlookup` (a lookup variant for overriding **defined-type**
  parameters globally or per-instance; calls `simplib::lookup` under the hood,
  `dlookup.rb`); `simplib::mock_data` (a Hiera `mock_data` backend for
  tests, `mock_data.rb`).
- **Password generation** — `simplib::passgen` generates/retrieves a persistent
  random password for an identifier in one of **two modes**: **simpkv** (stored
  in a key/value store via the `simp/simpkv` module) or **legacy** (stored as
  files under `Puppet.settings[:vardir]/.../simp_autofiles/gen_passwd/`). simpkv
  mode is enabled by setting `simplib::passgen::simpkv: true` in Hiera; minimum
  length is 8 (`passgen.rb`). The `passgen/` submodule
  (`lib/puppet/functions/simplib/passgen/`) holds the get/set/list/remove
  helpers plus separate `simpkv/*` and `legacy/*` implementations.
  `simplib::gen_random_password` is the underlying stateless generator (no
  persistence).
- **Validation** (fail compilation on bad input) — `simplib::validate_bool`,
  `validate_net_list`, `validate_port`, `validate_between`,
  `validate_array_member`, `validate_deep_hash`, `validate_re_array`,
  `validate_uri_list`, `validate_sysctl_value`.
- **Network / IP helpers** — `simplib::nets2cidr` (netmask → CIDR, hostnames
  passed through, `nets2cidr.rb`), `nets2ddq`, `ipaddresses`, `bracketize`
  (wrap IPv6 in `[]`), `strip_ports`, `parse_hosts`, `host_is_me`, `ip_to_cron`,
  `rand_cron`, `join_mount_opts`.
- **Ecosystem / meta** — `simplib::assert_optional_dependency` (fails the
  compile if a module listed in the caller's `metadata.json`
  `simp.optional_dependencies` is missing or version-mismatched; **other SIMP
  modules call this to guard optional integrations**, `assert_optional_dependency.rb`);
  `simplib::deprecation` (deduped per-key deprecation warning,
  `deprecation.rb`); `simplib::module_exist`, `caller`, `simp_version`,
  `filtered`, `params2hash`, `to_integer`, `to_string`, and the
  `debug/{classtrace,stacktrace,inspect}` helpers.
- **Puppet-language functions (`functions/`)** — a separate, smaller set of
  `.pp` functions (not Ruby): `assert_metadata`, `hash_to_opts`, `in_bolt`,
  `inspect`, `knockout`, `safe_filename`, `error`, plus `cron/`, `ldap/`, and
  `module_metadata/` subdirs.

**Custom data types (`types/`, 15 top-level aliases plus namespaced subtypes).** These are
composed alias types — e.g. `Simplib::IP = Variant[Simplib::IP::V4,
Simplib::IP::V6]` (`types/ip.pp`), `Simplib::Host = Variant[Simplib::IP,
Simplib::Hostname]` (`types/host.pp`), `Simplib::Netlist = Array[Variant[...]]`
(`types/netlist.pp`), `Simplib::Port = Variant[Port::Random, Port::System,
Port::User, Port::Dynamic]` (`types/port.pp`). Families: IP/network
(`ip/`, `netlist/`), host/domain (`host/`, `hostname/`, `domain*`, `emailaddress`),
port (`port/`), syslog (`syslog/` facility/severity/priority in string and C
forms), cron (`cron/`), crypt-hash formats (`libcrypt/`, e.g. bcrypt / SHA-256 /
SHA-512), systemd (`systemd/`), and standalone aliases (`packageensure`,
`umask`, `macaddress`, `uri`, `shadowpass`, `puppetloglevel`,
`serverdistribution`).

**Custom facts (`lib/facter/`, 33).** Notable ones:

- `fips_enabled` — reads `/proc/sys/crypto/fips_enabled`; Linux-confined
  (`fips_enabled.rb`). (Consumed by `simp/fips`.)
- `reboot_required` — scans `/var/run/puppet/reboot_triggers/*` and returns a
  `name => reason` hash, or `false` if empty (`reboot_required.rb`). This
  pairs with the `reboot_notify` custom type, which writes those triggers.
- `boot_dir_uuid` / `root_dir_uuid` — partition UUIDs of `/boot` and `/` via
  `df` + `blkid` (`boot_dir_uuid.rb`).
- `init_systems` — which init systems are present (`rc`/`upstart`/`systemd`/
  `sysv`) by probing for binaries and directories (`init_systems.rb`).
- `cpuinfo` — `/proc/cpuinfo` parsed per-processor into a hash.
- `simplib__*` namespaced facts — `simplib__crypto_policy_state`,
  `simplib__secure_boot_enabled`, `simplib__efi_enabled`, `simplib__mountpoints`,
  `simplib__auditd`, `simplib__sshd_config`, `simplib__firewalls`,
  `simplib__networkmanager`, `simplib__numa`. Plus `ipv6_enabled`, `cmdline`,
  `defaultgateway(iface)`, `login_defs`, `uid_min`, `simp_puppet_settings`, and
  others.

**Custom resource types + providers (`lib/puppet/type/`, 7).**
`reboot_notify` (writes a summary file of reboot reasons; **registers entries
only on refresh** — the driver behind the `reboot_required` fact,
`type/reboot_notify.rb`), `ftpusers`, `init_ulimit`, `prepend_file_line`,
`runlevel`, `script_umask`, `simp_file_line`.

### Gotchas / non-obvious details

- **This is a fleet-wide dependency.** Almost every SIMP module lists
  `simp/simplib` in `metadata.json`. Treat the function signatures, type
  definitions, and fact names/shapes as a **public API** — renaming or changing
  the return shape of a fact/function/type can break downstream modules.
- **`simplib::lookup` is not `lookup()`.** It checks global scope (declared class params / ENC) *before* the Hiera back-ends, but only honors a global value when it is *truthy* — a global `false`/`undef` falls through (`lib/puppet/functions/simplib/lookup.rb`, `return global_param if global_param`). Don't assume it behaves like stock `lookup()`.
- **`simplib::passgen` persists secrets.** In legacy mode it writes password
  files under the Puppet `vardir`; in simpkv mode it writes to the configured
  key/value store. Which one runs depends on the `simplib::passgen::simpkv`
  Hiera flag (`passgen.rb`). This is why **`simp/simpkv` is a hard runtime
  dependency** even though nothing in the three manifests references it.
- **`reboot_notify` only records on refresh.** The custom type registers a
  reboot reason **only when it receives a refresh event**; a plain declaration
  won't (`lib/puppet/type/reboot_notify.rb`). The `reboot_required` fact
  then reports those triggers until the host reboots.
- **`simplib::install` is a define, not a function**, specifically so its
  `Package` resources are addressable for ordering (`manifests/install.pp`).
- **No `assert_private()` anywhere in the manifests** — all three classes/defines
  are public and meant to be `include`d/declared directly.
- **This module does not consume the `simp_options::` seam** — see below.

## The `simp_options` / `simplib::lookup` seam

`simplib` **provides** `simplib::lookup` (and `simplib::assert_optional_dependency`)
for the rest of the fleet; it does **not consume** the `simp_options::*` seam
itself. There are **no `simplib::lookup('simp_options::…')` calls in this
module's manifests** — the three manifests take plain typed parameters and read
no `simp_options` keys. (Contrast a consumer module like `simp/fips`, whose
`init.pp` looks up `simp_options::fips` / `simp_options::package_ensure` *through*
`simplib::lookup`.) So there is no `simp_options` lookup table to maintain here.

When adding logic to simplib that must respect a SIMP-wide toggle, use
`simplib::lookup('simp_options::<key>', { 'default_value' => ... })` with an
explicit default — do not assume `simp_options` is declared. But most changes to
simplib belong in the reusable functions/types/facts, not in a new
`simp_options` consumer.

## Dependencies

Module dependencies (from `metadata.json`):

- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0` — provides `ensure_packages`, the
  stdlib run stages (`stdlib::stages`), etc.
- `simp/simpkv` `>= 0.7.0 < 2.0.0` — the key/value store backing
  `simplib::passgen`'s simpkv mode.

**No optional dependencies are declared** in `metadata.json`. (Note: simplib is
the module that *provides* `simplib::assert_optional_dependency`, the function
other modules use to guard *their* optional dependencies — it just doesn't
declare any of its own.)

Runtime requirement (from `metadata.json` `requirements`): **`openvox >= 8.0.0
< 9.0.0`**. This module names **openvox** (not `puppet`) — it is on the new
OpenVox baseline. SIMP is migrating Puppet → OpenVox; simplib is already
switched.

Supported OS matrix (from `metadata.json`): CentOS 9/10; RedHat 8/9/10;
OracleLinux 8/9/10; Rocky 8/9/10; AlmaLinux 8/9/10.

## Repository layout

- `manifests/reboot_notify.pp` — `simplib::reboot_notify` controller class.
- `manifests/stages.pp` — `simplib::stages` (adds `simp_prep` / `simp_finalize`).
- `manifests/install.pp` — `simplib::install` defined type.
- `lib/puppet/functions/` — ~56 Ruby functions (most under `simplib/`; the
  `passgen/` subtree holds the simpkv/legacy password implementations).
- `functions/` — the smaller set of Puppet-language (`.pp`) functions.
- `types/` — 15 top-level custom data-type aliases (with subtype dirs `ip/`, `host/`,
  `hostname/`, `netlist/`, `port/`, `cron/`, `syslog/`, `systemd/`, `libcrypt/`,
  `puppet/`).
- `lib/facter/` — 33 custom facts (`fips_enabled`, `reboot_required`, the
  `simplib__*` family, …).
- `lib/puppet/type/` + `lib/puppet/provider/` — 7 custom resource types with
  providers (`reboot_notify`, `simp_file_line`, `runlevel`, …).
- `metadata.json` — deps, OS matrix, and the `openvox` runtime requirement.
- `spec/` — unit tests (rspec-puppet) and acceptance suites (beaker).
- `REFERENCE.md` — generated Puppet Strings reference.
- **Acceptance runs in CI:** `.github/workflows/pr_tests.yml` has an
  `acceptance` job (`pr_tests.yml`) that runs beaker on **docker nodes via
  podman** — it starts the user podman socket and exports
  `DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock`
  (`pr_tests.yml`). Suite matrix: `default`, `caller_function`,
  `prelink_fact`; node matrix: `docker_alma8/9/10`, `docker_centos9/10`,
  `docker_oel8/9/10`, `docker_rocky8/9/10` (the `docker_rhel8/9/10` nodes are
  present but **commented out** — RHEL UBI containers can't install packages
  without a subscription, `pr_tests.yml`). The `ipa_fact` and `windows`
  suites exist on disk but are excluded from CI. The workflow also runs the
  standard syntax / style / file-checks / releng-checks / spec-tests jobs.
- `spec/acceptance/nodesets/` — 29 nodeset files.

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run unit tests in parallel (as CI does)
bundle exec rake parallel_spec

# Run a single spec file
bundle exec rspec spec/functions/lookup_spec.rb

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run an acceptance suite on a docker node (matches CI; requires podman)
bundle exec rake beaker:suites[default,docker_alma9]
```

The `Gemfile` defaults `puppet_version` to `['>= 8', '< 9']` (`Gemfile`) and
installs **both** the `openvox` and `puppet` gems during the OpenVox transition
via `['openvox', 'puppet'].each do |gem_name|` (`Gemfile`). Relevant pins:
`puppetlabs_spec_helper ~> 8.0.0` (`Gemfile`), `simp-rake-helpers ~> 5.24.0`
(`Gemfile`), `simp-beaker-helpers ~> 2.0.0` (`Gemfile`), and
`rubocop ~> 1.88.0` (`Gemfile`). `spec/spec_helper.rb` requires
`puppetlabs_spec_helper/module_spec_helper`.

## Conventions

- **Treat the Ruby surface as public API.** Functions, custom types, facts, and
  the custom resource types are consumed fleet-wide — preserve names,
  signatures, return shapes, and type definitions. Deprecate with
  `simplib::deprecation` rather than removing outright.
- Preserve the `@summary` / `@param` / `@option` puppet-strings docstrings on
  functions, types, and classes — they drive `REFERENCE.md`. Regenerate
  `REFERENCE.md` after changing docs, parameters, or type definitions.
- Custom data types are **composed** — build new ones from existing subtypes
  (as `Simplib::Netlist` composes `Simplib::Host` / `Simplib::IP::CIDR`) rather
  than duplicating regexes.
- Custom facts that gather SIMP-specific data use the **`simplib__` prefix**;
  keep that convention for new facts, and `confine` platform-specific facts (as
  `fips_enabled` / `boot_dir_uuid` do) so they resolve cleanly on unsupported
  platforms.
- Password generation must go through the `simplib::passgen` mode switch —
  don't hard-code the legacy file path or bypass simpkv; respect
  `simplib::passgen::simpkv`.
- `Gemfile`, `spec/spec_helper.rb`, and `.github/workflows/pr_tests.yml` carry a
  **puppetsync** notice — they are baseline-managed and the next sync overwrites
  local edits. Push changes to those files upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter
  style used in the manifests and type definitions.
