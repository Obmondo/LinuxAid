# AGENTS.md

## Scope
Guidance for agentic coding tools working in this LinuxAid repository.

LinuxAid is a Puppet/OpenVox codebase with:
- Environment entry manifests in `manifests/`
- First-party modules in `modules/enableit/`
- Vendored/third-party modules in `modules/upstream/`
- CI workflows in `.gitea/workflows/` and `.github/workflows/`

## Cursor / Copilot Rules
Checked for repository-specific agent rules in:
- `.cursorrules`
- `.cursor/rules/`
- `.github/copilot-instructions.md`

Current status:
- No Cursor rules found
- No Copilot instructions file found

If these files are added, treat them as higher-priority instructions and update this file.

## Key Paths
- `manifests/site.pp`: top-level role selection and guardrails
- `manifests/defaults.pp`: shared defaults
- `modules/enableit/`: first-party LinuxAid logic
- `modules/upstream/`: externally sourced modules
- `.puppet-lint.rc`: root puppet-lint config
- `.yamllint`: root YAML lint config
- `bin/`: helper scripts (release/docs)

## Build, Lint, and Test Commands
This repo is module-oriented, not a single-app build. Run checks from impacted module roots.

### Root-level checks
```bash
yamllint -c .yamllint .
```

```bash
puppet-lint --config .puppet-lint.rc manifests/**/*.pp modules/enableit/**/*.pp
```

Notes:
- `.yamllint` ignores `modules/upstream`
- root puppet-lint config relaxes some defaults (for legacy compatibility)

### Typical module workflow (Ruby/Bundler/Rake)
From an affected module directory (examples: `modules/enableit/thinlinc`, `modules/upstream/apache`):
```bash
bundle install --path vendor/bundle
bundle exec rake -T
bundle exec rake lint
bundle exec rake validate
bundle exec rake spec
```

Common optional tasks (module-dependent):
```bash
bundle exec rake test
bundle exec rake rubocop
bundle exec rake parallel_spec
bundle exec rake syntax lint metadata_lint check:symlinks check:git_ignore check:dot_underscore check:test_file rubocop
```

### Running a single test (important)
Preferred patterns:
```bash
bundle exec rake spec SPEC=spec/path/to/file_spec.rb
bundle exec rspec spec/path/to/file_spec.rb
bundle exec rspec spec/path/to/file_spec.rb:LINE
```

Use file+line targeting for fast iteration when fixing one expectation.

### Modules with partial scaffolding
Some first-party modules (for example `modules/enableit/functions`) include `Rakefile`/specs but no local `Gemfile`.
In those cases:
- run available `rake`/`rspec` tasks in the current environment, or
- use the project CI/container image if local dependencies are missing

## CI Signals to Mirror
Primary PR CI is in `.gitea/workflows/puppet.yaml` and includes:
- shell lint/check scripts
- EPP lint
- ERB lint
- Puppet + puppet-lint checks
- secret scanning over `modules/enableit`
- JSON lint
- YAML lint

Agent behavior:
- if you edit `*.pp`, `*.epp`, `*.erb`, `*.sh`, or `*.json`, run matching local checks when possible
- if exact CI scripts are unavailable locally, run closest equivalent and call out the gap

## Style Guidelines

### General
- Keep edits minimal, scoped, and consistent with nearby code
- Do not refactor unrelated files while implementing a targeted fix
- Preserve existing behavior unless the task explicitly changes it
- Add/update tests when behavior changes

### Puppet (`.pp`)
- Use 2-space indentation and existing alignment conventions
- Prefer typed parameters for class/defined type APIs
- Keep Hiera lookups explicit (`lookup(...)`) with defaults/types when practical
- Prefer `$facts[...]`-based decisions over shell calls
- Use `contain`/`include` consistently with local module style
- Keep titles/resource names stable and descriptive
- Fail early for invalid role combinations or unsupported states
- Write actionable failure messages (what failed, what to fix)

### Ruby (functions, facts, providers)
- Follow module `.rubocop.yml` when present
- Keep `require` statements at top of file
- Validate arguments and raise specific errors (`ArgumentError`, etc.)
- Rescue narrowly (expected exceptions only), re-raise with context
- Avoid silent rescue/fallbacks that hide misconfiguration
- Keep helpers small and side effects explicit

### Imports and dependencies
- Puppet: add explicit ordering/dependencies only when necessary
- Ruby: require only what is needed
- Do not introduce heavy/new dependencies without clear necessity

### Naming
- Puppet class/type names: lowercase snake_case + namespace (`module::subclass`)
- Role classes follow existing `role::...` patterns
- Variables: descriptive snake_case
- Specs: `*_spec.rb`, usually mirroring implementation paths

### Formatting and docs
- Avoid mass reformatting unrelated blocks
- Preserve heredoc/template style already used in file
- Keep Puppet Strings docs in sync for public module interfaces where used

## Error Handling Expectations
- Puppet: use `fail()` for compile-time invalid states that must stop catalog compilation
- Ruby: validate inputs early and raise precise exceptions
- External I/O (HTTP/files): handle expected failure modes and include context in raised errors

## Change Boundaries and Safety
- Prefer changes in `modules/enableit` for LinuxAid behavior
- Touch `modules/upstream` only when task explicitly requires it
- Never commit secrets, certs, keys, or environment credentials
- Do not run release/tag/push flows unless explicitly requested

## Practical Workflow for Agents
1. Identify touched modules/files.
2. Run narrow tests first (single spec file or line).
3. Run module lint/validate/spec tasks.
4. Run root checks if change spans multiple modules or YAML/manifest roots.
5. Report commands actually run and anything not runnable locally.
