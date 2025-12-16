# How LinuxAid Compares to Alternatives

All of the tools below have legitimate strengths and shared challenges. LinuxAid builds on the OpenVox (Puppet-compatible) stack to provide an "operations-in-a-box" experience, while Ansible, Terraform, Chef, and SaltStack remain highly capable when paired with the right processes.
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

- **LinuxAid:** Uses Puppet noop mode plus OpenVoxDB to calculate impact across every node. Agents run on a pull schedule, so configuration drift is corrected automatically and reviewers can group catalogs into "patterns" before rollout. Like all preview modes, accuracy depends on resource types and interdependencies.

- **Ansible:** Check mode combined with AWX job templates can surface diffs, but not all modules support check mode (particularly shell/command modules), and playbook authors can override it. Normally requires inventories, callback plugins, and organizational discipline to keep every change in Git.

- **Terraform:** `terraform plan` is authoritative for infrastructure and generally reliable for cloud resources, yet each workspace must be evaluated separately and the tool does not remediate in-guest drift.

- **Chef:** `why-run` mode exists but Chef's own engineering team has documented significant limitations - it cannot accurately predict changes when resources have dependencies because it evaluates in isolation without modifying the system. Chef recommends InSpec for compliance validation rather than relying on why-run for preview accuracy.

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
