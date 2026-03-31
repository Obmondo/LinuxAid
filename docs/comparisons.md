# How LinuxAid Compares to Alternatives

All of the tools below have legitimate strengths and shared challenges. LinuxAid builds on the OpenVox (Puppet-compatible) stack to provide an "operations-in-a-box" experience, while Ansible, Terraform, Chef, and SaltStack remain highly capable when paired with the right processes.

---

## Design Philosophy: Idempotency at the Core

The most fundamental difference between LinuxAid (built on the Puppet/OpenVox stack) and tools like Ansible or Terraform lies in its **idempotent, declarative design**. This architectural distinction enables capabilities that are difficult or impossible to replicate with imperative or partially-declarative tools.

### What Does Idempotent Mean?

**Idempotency** means you can safely run the same operation 10 times, or 1,000 times, and it will always end with the same result. The first run makes the necessary changes to reach your desired state; subsequent runs recognize that everything is already as it should be and change nothing.

### The Declarative Resource Model

In LinuxAid/Puppet, your Infrastructure as Code is written in **Puppet DSL**,a language purpose-built to *describe* resources rather than *execute commands*:

```puppet
# You describe WHAT you want, not HOW to do it
file { '/etc/myapp/config.conf':
  ensure  => file,
  content => template('myapp/config.conf.erb'),
  owner   => 'appuser',
  mode    => '0644',
}

service { 'myapp':
  ensure    => running,
  enable    => true,
  subscribe => File['/etc/myapp/config.conf'],
}
```

You define the **resources** you want to manage (files, services, packages, users, etc.) and write logic that, based on **facts** about each system, accurately describes those resources. Your code handles different operating systems and situations automatically because you focus only on the desired end state.

When the agent on each client receives this compiled catalog describing "what you want as an end result," **it already knows how to get the resources to that state**, whether that means running `apt`, `yum`, `zypper`, `systemctl`, or any platform-specific command.

### Why This Architecture Matters

This design enables two critical capabilities that set LinuxAid apart:

#### 1. True State Verification, Not Command Preview

| Tool | Dry-Run Behavior |
|------|------------------|
| **LinuxAid/Puppet** | Shows exactly **what is out of sync** with your wanted state by *verifying actual system state* |
| **Ansible** | Shows **what commands it would run**, but doesn't verify current state |
| **Terraform** | Compares against **its own state file**, which may be out of sync with reality if someone changed infrastructure outside Terraform |

**This is not a per-module feature you can forget to implement.** In Puppet, every resource type inherently supports this behavior. Ansible module authors must implement check mode themselves, each in their own way, leading to inconsistent coverage. Terraform relies on you to manually reconcile its state file when external changes occur.

#### 2. Fleet-Wide Diff with Changeset Grouping

When you modify your code, you can run a diff against **all your servers at once** and see exactly what will change compared to the current state. The output is designed so you can easily split thousands of servers into a small number of **distinct changesets**.

**Real-world example:** A team managing 300 servers needed to roll out a major infrastructure change. Running a fleet-wide diff produced only **5 unique changesets**, each with a list of which servers it applied to. Instead of reviewing 300 individual changes, they validated just 5 patterns, dramatically reducing review time and risk.

This capability is why organizations managing very large fleets choose Puppet:

| Organization | Scale | Tool |
|--------------|-------|------|
| **Nordea** (Denmark) | 30,000+ servers | Puppet |
| **AWS** | 100,000+ servers | Puppet |

These enterprises need the confidence that comes from true idempotency and fleet-wide state verification before rolling out changes to critical infrastructure.

---

## Comparison Topics at a Glance

| # | Topic | LinuxAid | Ansible | Terraform | Chef | SaltStack | Details |
|---|-------|--------------------|---------|-----------|------|-----------|---------|
| 1 | Change preview & drift control | ✅ Fleet-wide noop runs, OpenVoxDB | ⚠️ Check mode + AWX | ⚠️ Plan per workspace | ⚠️ Why-run (limited accuracy) | ⚠️ Test mode (limited diffs) | [How it works](#1-change-preview--drift-control) |
| 2 | Compliance frameworks & reporting | ✅ GDPR/CIS/NIS2 data + OpenVoxDB audits | ⚠️ Lockdown/AWX roles | ⚠️ Policy-as-code only | ✅ InSpec + Automate | ⚠️ Requires modules | [What's included](#2-compliance-frameworks--reporting) |
| 3 | Supply chain security & air-gap | ✅ Repository server, GPG signing, snapshots | ⚠️ Manual hardening | ⚠️ Module-by-module | ⚠️ Custom pipeline | ⚠️ Custom pipeline | [Why it matters](#3-supply-chain-security--air-gap) |
| 4 | Scale & performance track record | ✅ Puppet-style compile masters (20k+ nodes documented) | ⚠️ AWX scale tuning | ⚠️ State file workflows | ✅ Enterprises documented | ✅ Enterprises documented (5k+ per master) | [Evidence & tuning](#4-scale--performance) |
| 5 | Application catalog & monitoring | ✅ 60+ bundled roles + Prometheus/Grafana | ⚠️ Galaxy role quality varies | ❌ Focused on infra provisioning | ⚠️ Cookbook marketplace | ⚠️ Community states | [What you get](#5-application-support--monitoring) |
| 6 | Data ownership & GitOps | ✅ All configs in customer Git + pull model | ✅ Possible with AWX | ⚠️ Needs policy repos | ✅ Chef Automate workflows | ✅ GitFS/raas | [Workflow notes](#6-data-ownership--gitops) |
| 7 | Operational maturity & anti-patterns | ✅ Pull-based, no prod SSH, change grouping | ⚠️ Discipline required | ⚠️ State locking & per-env plans | ✅ Similar guardrails | ✅ Similar guardrails | [Operational guidance](#7-operational-maturity--anti-patterns) |

Legend: ✅ Built-in/default · ⚠️ Requires additional tooling/process or has known limitations · ❌ Not a stated focus area

---

### 1. Change Preview & Drift Control

**Important context:** All configuration management tools face inherent challenges with accurate change preview when resources have dependencies or dynamic runtime conditions. No dry-run mode is 100% accurate across all scenarios.

- **LinuxAid:** Uses Puppet noop mode plus OpenVoxDB to calculate impact across every node. Unlike tools that show "what commands would run," LinuxAid **verifies actual system state** and shows exactly what is out of sync with your desired configuration. Agents run on a pull schedule, so configuration drift is corrected automatically, no manual state file reconciliation required when external changes occur. The fleet-wide diff output is designed for changeset grouping: when rolling out a change to 10,000 servers, you typically see only a handful of distinct changesets, making review practical even at massive scale.

- **Ansible:** Check mode shows "what commands would run" rather than verifying current system state. Not all modules support check mode (particularly shell/command modules), and each module author implements it differently in their own way, so coverage is inconsistent and you can't rely on it uniformly. Playbook authors can override check mode, and organizational discipline is required to keep every change in Git.

- **Terraform:** `terraform plan` compares your configuration against **its own state file**, not the actual infrastructure. If someone (a person, script, or another tool) changes resources outside Terraform, you must manually reconcile the state file with `terraform import` or `terraform state rm`. Each workspace must be evaluated separately, and Terraform does not remediate in-guest configuration drift.

- **Chef:** `why-run` mode exists but Chef's own engineering team has documented significant limitations, it cannot accurately predict changes when resources have dependencies because it evaluates in isolation without modifying the system. Chef recommends InSpec for compliance validation rather than relying on why, run for preview accuracy.

- **SaltStack:** `test=true` provides previews, though recent versions have known issues with diff output showing only "The file is set to be changed" rather than detailed changes. Agents also heal drift, but reporting must be assembled via event buses or custom tooling.

### 2. Compliance Frameworks & Reporting

- **LinuxAid:** Ships GDPR/CIS/NIS2 data with the Hiera hierarchy and logs every catalog compile plus agent report into OpenVoxDB for audit trails.

- **Ansible:** The Lockdown/STIG role collections plus AWX/Tower RBAC provide strong compliance capabilities, though each customer assembles the pieces.

- **Terraform:** Policy-as-code (OPA/Sentinel) governs cloud provisioning, so OS-level hardening usually needs another tool.

- **Chef:** InSpec and Chef Automate include 70+ certified CIS/STIG profiles updated bi-weekly, offering comprehensive compliance dashboards with remediation tracking.

- **SaltStack:** Salt Compliance and community formulas cover many benchmarks, but breadth depends on which states you maintain.

### 3. Supply Chain Security & Air-Gap

- **LinuxAid:** Includes the repository server role with mirroring, GPG signing, packagesign daemon, and snapshot-based staged rollouts so fully air-gapped installs keep provenance.

- **Ansible / Terraform / Chef / SaltStack:** All can meet supply-chain requirements, yet you must wire in your own artifact repos, signing policies, and CI validation. None ships a turnkey package repository.

### 4. Scale & Performance

- **LinuxAid:** Builds on Puppet's documented ability to support 20,000+ nodes per compile tier, with horizontal expansion via compile masters and PuppetDB/PostgreSQL sharding. Some deployments reach 60,000-100,000 nodes.

- **Ansible:** AWX/Automation Platform scales by adding execution nodes and Redis/DB replicas; operators manage inventory sharding and execution-queue sizing.

- **Terraform:** Scale hinges on remote state backends (S3, Consul, Terraform Cloud). Large environments juggle locking, drift detection, and re-plan choreography.

- **Chef / SaltStack:** Both platforms have large enterprise references; Chef supports extensive deployments while SaltStack Config Enterprise handles up to 5,000 minions per master. Tuning typically focuses on message bus fan-out, database sizing, and environment segmentation.

### 5. Application Support & Monitoring

- **LinuxAid:** Maintains 60+ tested role/profile stacks (Mailcow, GitLab, HAProxy, etc.) plus fact-driven monitoring that deploys exporters, Grafana dashboards, and Alertmanager routing automatically.

- **Ansible:** Galaxy offers thousands of roles, but quality and maintenance cadence vary and integrated monitoring must be curated project by project.

- **Terraform:** Focused on provisioning, so you normally pair it with another configuration system for app lifecycle and observability.

- **Chef / SaltStack:** Cookbook/state ecosystems are broad yet similarly depend on curation; monitoring integrations are available but rarely plug-and-play.

### 6. Data Ownership & GitOps

- **LinuxAid:** Runs entirely from the customer's Git repositories; agents pull from central infrastructure so every change is versioned, reviewed, and replayable without vendor lock-in.

- **Ansible:** GitOps patterns (AWX project sync, RBAC, approvals) are available and work well when consistently applied.

- **Terraform:** Git + CI/CD is the norm, yet runtime state lives in the backend so additional guardrails are required for operational data.

- **Chef / SaltStack:** Policyfiles, GitFS, and Reclass make Git-centric workflows possible, though teams often need onboarding support to standardize conventions.

### 7. Operational Maturity & Anti-Patterns

- **LinuxAid:** Pull-based enforcement plus OpenVoxDB change grouping discourages "quick SSH fixes" and keeps evidence ready for ISO 27001/NIS2 audits.

- **Ansible:** Excels at ad-hoc automation, which is powerful but can lead to drift if teams bypass playbooks; AWX approvals mitigate risk when consistently applied.

- **Terraform:** Enforces declarative intent but relies on state locking and workspace hygiene to prevent cross-team conflicts.

- **Chef / SaltStack:** Offer similar guardrails to LinuxAid; success depends on treating their agents as the single source of truth and keeping manual changes out of production.
