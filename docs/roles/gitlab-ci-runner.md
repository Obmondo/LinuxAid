# GitLab CI Runner Role (`role::projectmanagement::gitlab_ci_runner`)

## Overview

The `role::projectmanagement::gitlab_ci_runner` class provisions and
manages GitLab CI/CD runners. It supports both Docker container executors
and shell runners with per-user service isolation.

## Features

- **Docker Executors**: Provision isolated Docker container execution
  environments for CI/CD jobs.
- **Shell Runners with User Isolation**: Provides dedicated user account
  isolation for shell-based CI workloads.
- **Automated Registration**: Registers runners with GitLab instances
  using registration tokens stored in encrypted Hiera (`eyaml`).

## Usage

Assign the role to a dedicated runner node in Hiera:

```yaml
classes:
  - role::projectmanagement::gitlab_ci_runner
```

## Configuration

Configure runner options in Hiera:

```yaml
profile::projectmanagement::gitlab_ci_runner::runner_type: 'shell'
profile::projectmanagement::gitlab_ci_runner::concurrent_jobs: 4
```

## Related Documentation

- [Eyaml Guide](../guides/eyaml.md)
- [Roles Reference](./README.md)
