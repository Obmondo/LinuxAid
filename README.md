# LinuxAid

A platform for everything you need to run a secure and reliable Linux operations setup

## Config options

Under each module that you use in linuxaid-config tree - you can see the documentation for it the corresponding REFERENCE.md file - following the Puppet standard way of documenting modules.

For LinuxAid we have built these modules:

- [Roles](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/role/REFERENCE.md) - the list of roles (software and configs we support currently). Note some roles support mixing - so multiple roles cannot always be assigned to a server, as they can conflict.
- [Common settings](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md) - the list of common configurations you can rollout for any server, regardless of its configured role.
- [Monitoring settings](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/monitor/REFERENCE.md) - settings for monitoring

These options can be applied in different scopes and by default LinuxAid has been built to support applying options based on:

- **Tags** - which is just a group - given by Puppet ENC. 
  TODO: Document ENC features and custom tag support.
- **Facts** - Which is 'knowledge about a system' and you can define config for any fact, including:
  - OS, Distribution, software versions installed or versions of these
  - Location
  - specific hardware configurations, like which raid controller or how much memory etc.

  We have over 7k facts - and we then filter that down by default to avoid clogging up the database necessary. This filter is adjustable, should you find you want to use some of the facts we've chosen not to use by default. See [Facts](./docs/facts) for details.

### Hierarchical Data Management with Hiera

LinuxAid leverages Hiera's hierarchical data lookup system for sophisticated data separation from code.

**Benefits:**
- Same codebase across dev, staging, and production
- Override data at appropriate specificity levels (node, location, OS, etc.)
- Clear separation between code logic and environment-specific data
- Similar flexibility to Helm values in Kubernetes

NB. You can see the Hierarchy we've built to support this (and adjust as you want it) here: https://github.com/Obmondo/LinuxAid/blob/master/hiera.yaml#L10

### Strong Community Module Ecosystem

The Puppet community module ecosystem is the backbone of LinuxAid's capabilities:
- Well-tested, peer-reviewed implementations
- Standardized interfaces and patterns
- Easy to extend and customize
- 60+ supported applications out of the box
- Strong backward compatibility commitment

This distinguished Puppet from competitors like Chef, which failed due to lack of community modules.

## Security and Reliability

### Supply Chain Security

For Supply Chain Security we have built an [open source repository server](https://gitea.obmondo.com/EnableIT/LinuxAid/src/branch/master/modules/enableit/role/REFERENCE.md#role--package_management--repo).

It supports mirroring any upstream mirror you need to use for your servers - so you can run airgapped - and servers don't need internet access to function and be maintainable. It also enables staged rollouts.

It also has a daemon called packagesign, a separate open source project we wrote, that supports automatically pulling built rpm or deb packages from gitea, gitlab etc. build jobs - and gpg signing and adding them to your own repository.

**Protection Against Single-Point-of-Compromise:**

This is part of a design to protect against any single-point-of-compromise affecting you.

To do this, you need to gpg sign all commits on your branches, that builds these packages/releases (easily setup in .gitconfig) - and then on your runners (which are separate from and not managed by your Githost) - you need to enable it to run a security check, that validates ALL gpg signatures on the git repo cloned - before the CI job is allowed to run.

This protects against a compromised Githost - as they can inject code into your repo.. but once thats cloned by a runner - the job will not be allowed to run.

This way - they cannot sneak anything into your release packages.

### Staged rollouts

Using our reposerver role, you can enable automatic snapshots - which will simply make hardlink based snapshots of all repositories, so that you can split your servers into groups, and assign a snapshot to 1 group at a time, and roll out security updates to them.

You can do the same for your LinuxAid configuration (the puppet and/or hiera tree) if you want - by simply making git branches or tags - and locking servers to an environment.

### GitOps

LinuxAid was built on Puppet (Now OpenVox), which was designed for centralized management and GitOps, which enables:

- **Changelog of everything done on your systems**
  Also required by ISO 27001:2022 and ITILv4, and required several regulations and rules all over the world, incl. NIS2.
  TODO: Add links to these requirements (in our upcoming compliance helper - coming on Obmondo)

- **All changes through central server**
  Similar to what Ansible Tower provides (as a paid add-on), LinuxAid's architecture makes centralized control a core feature:
  - All changes flow through the Puppet server
  - Complete logging and auditability
  - No direct SSH to systems for "quick fixes"
  - Prevents the anti-pattern of undocumented manual changes

- **Branch-based development and testing**
  - Develop features in feature branches
  - Test changes against real systems using branch-specific catalogs
  - Merge to main only after validation
  - No need to maintain separate test infrastructure

- **System built for making it easy to actually develop the GitOps way**
  TODO: add link to OpenVox (LinuxAid edition) vs. Ansible/Terraform docs - GitOps

- **Using standardized code review methods, for your operations setup too**
  Everything's a Pull Request now.

- **Supply Chain Security on operations**
  See the GPG signing feature in the [Supply Chain Security](#supply-chain-security) section above.

### Compliance Built-In

LinuxAid ensures GDPR, CIS, and NIS2 compliance through its architecture:
- Audit-ready change tracking
- Separation of duties (no production SSH needed)
- Reproducible system states
- Configuration baselines enforcement
- Drift detection and correction

## Monitoring

LinuxAid includes monitoring of everything we have ever needed for any customer we have had and we constantly add support and gladly accept PRs :)

Because LinuxAid is built on Puppet (Now OpenVox - the Open Source community fork), it automatically detects your hardware and everything else on your system, using a system called 'facts' - of which there's 1000's - and configures your server according to these facts, with the right monitoring (and everything else).

**Observability Stack:**
- Prometheus for metrics tracking
- Grafana dashboards
- Alert Manager with custom rules and pre-defined thresholds

### High Availability

We run the LinuxAid setup under a Kubernetes setup - documented in KubeAid (see below details link) - and this CAN be spun up on a single-host Linux server if you want, but it means you can have a High availability setup, very easily.

**Scalable Architecture:** The OpenVox Server (formerly Puppet Server) is written in Clojure with workload separation:
- **Compiler:** Builds catalogs (CPU-intensive work)
- **API Layer:** Handles agent communications
- **Independent scaling:** Scale components based on workload

See the technical details on [monitoring here](https://github.com/Obmondo/LinuxAid/blob/master/docs/monitoring/monitoring.md)

## Proven at Enterprise Scale

Puppet's architecture has been proven at massive scale:

- **GitHub:** Thousands of nodes, 500,000+ lines of Puppet code, 200+ contributors, thousands of catalog-diff runs per day in CI/CD
- **AWS:** ~100,000 servers managed with Puppet
- **eBay:** ~100,000 servers under Puppet management
- **Nordea:** 30,000+ servers in highly regulated banking environment
- **Thousands of enterprises** running production workloads across industries

These organizations chose this architecture because alternative approaches **don't scale operationally**. The catalog-diff capability alone becomes essential when contemplating changes across tens of thousands of heterogeneous systems with hundreds of contributors.

**LinuxAid is built on this same proven architecture.** Based on OpenVox (the open-source community fork of Puppet), LinuxAid leverages decades of proven operational patterns while adding years of Obmondo's expertise, delivering multiple supported applications, built-in compliance frameworks (GDPR, CIS, NIS2), and enterprise-grade monitoring out of the box. This provides production readiness at enterprise scale without the years of development effort these organizations invested.
## 100% Data Ownership

LinuxAid provides true data ownership, your setup runs on your servers, even after subscription ends:
- Your infrastructure code remains on your systems
- No vendor lock-in
- Complete control over your operations
- Can be hosted on-premises or in any cloud

---

## How LinuxAid Compares: Where Alternatives Fall Short

While other tools have their place, they struggle with the operational features that become critical at scale and in compliance-sensitive environments.

### Core Infrastructure Management

| Feature | LinuxAid | Ansible | Terraform | Chef | SaltStack |
|---------|----------|---------|-----------|------|-----------|
| **State Management** | | | | | |
| Stateless (no state files) | ✅ | ✅ | ❌ | ✅ | ✅ |
| Automatic drift detection | ✅ | ❌ | ⚠️ Manual | ✅ | ✅ |
| Dynamic system querying | ✅ | ❌ | ❌ | ✅ | ✅ |
| State file corruption risk | ✅ None | ✅ None | ❌ High | ✅ None | ✅ None |
| **Change Management** | | | | | |
| Pre-deployment impact analysis | ✅ Catalog-diff | ❌ | ⚠️ Plan only | ❌ | ❌ |
| Preview across all systems | ✅ | ❌ | ⚠️ Limited | ❌ | ❌ |
| Reduce 30K servers to 5-7 patterns | ✅ | ❌ | ❌ | ❌ | ❌ |
| CI/CD integration (1000s runs/day) | ✅ GitHub | ❌ | ⚠️ Limited | ❌ | ❌ |
| **Validation & Safety** | | | | | |
| True dry-run vs real state | ✅ | ⚠️ Check | ⚠️ Plan | ✅ | ✅ |
| Automatic file backups | ✅ Built-in | ⚠️ Per-module | ❌ | ⚠️ Manual | ⚠️ Manual |
| Rollback capability | ✅ Auto | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |
| **Architecture** | | | | | |
| Pull-based model | ✅ | ❌ Push | ❌ API | ✅ | ✅ Both |
| No production SSH required | ✅ | ❌ | ✅ | ✅ | ✅ |
| Declarative resources | ✅ | ⚠️ Procedural | ✅ Infra | ✅ | ✅ |
| Automatic dependency resolution | ✅ Graph | ❌ Sequential | ✅ | ✅ | ⚠️ Limited |
| Define resources any order | ✅ | ❌ | ⚠️ Limited | ✅ | ⚠️ Limited |

**Legend:** ✅ Full support | ⚠️ Partial/Manual | ❌ Not supported

### Compliance & Security Comparison

| Feature | LinuxAid | Ansible | Terraform | Chef | SaltStack |
|---------|----------|---------|-----------|------|-----------|
| **Compliance** | | | | | |
| GDPR compliant | ✅ | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |
| CIS benchmarks | ✅ Built-in | ⚠️ External | ❌ | ⚠️ External | ⚠️ External |
| NIS2 compliant | ✅ | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |
| ISO 27001 ready | ✅ | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |
| Complete audit trail | ✅ Built-in | ⚠️ Tower only | ⚠️ Partial | ⚠️ Manual | ⚠️ Manual |
| GitOps native | ✅ | ⚠️ External | ✅ | ⚠️ External | ⚠️ External |
| All changes logged | ✅ Auto | ❌ | ⚠️ Partial | ⚠️ Manual | ⚠️ Manual |
| Separation of duties | ✅ Built-in | ❌ | ⚠️ Manual | ✅ | ⚠️ Manual |
| **Supply Chain** | | | | | |
| Repository server | ✅ Built-in | ❌ | ❌ | ❌ | ❌ |
| Air-gapped operation | ✅ | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |
| GPG signature validation | ✅ Built-in | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |
| Package signing daemon | ✅ Packagesign | ❌ | ❌ | ❌ | ❌ |
| Staged rollouts | ✅ Snapshots | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |
| Single-point protection | ✅ | ❌ | ❌ | ❌ | ❌ |

### Scale & Performance Comparison

| Feature | LinuxAid | Ansible | Terraform | Chef | SaltStack |
|---------|----------|---------|-----------|------|-----------|
| **Proven Scale** | | | | | |
| 100,000+ servers | ✅ AWS, eBay | ⚠️ Tower | ⚠️ Limited | ✅ Facebook | ✅ |
| 30,000+ servers | ✅ Nordea | ⚠️ Difficult | ❌ | ✅ | ✅ |
| 1000s contributors | ✅ GitHub | ❌ | ⚠️ Limited | ⚠️ Limited | ⚠️ Limited |
| 500,000+ lines code | ✅ GitHub | ❌ | ❌ | ⚠️ Rare | ⚠️ Rare |
| **Performance** | | | | | |
| Horizontal scaling | ✅ Components | ⚠️ Tower | ⚠️ Limited | ✅ | ✅ |
| Component scaling | ✅ Compiler/API | ❌ | ❌ | ✅ | ✅ |
| Agent efficiency | ✅ | ❌ | ❌ | ✅ | ✅ |

### Configuration & Monitoring Comparison

| Feature | LinuxAid | Ansible | Terraform | Chef | SaltStack |
|---------|----------|---------|-----------|------|-----------|
| **Data Management** | | | | | |
| Hierarchical data | ✅ Hiera | ⚠️ Vars | ⚠️ Variables | ⚠️ Data bags | ✅ Pillar |
| Code/data separation | ✅ Excellent | ⚠️ Basic | ⚠️ Basic | ✅ Good | ✅ Good |
| Environment overrides | ✅ | ⚠️ Limited | ⚠️ Workspaces | ✅ | ✅ |
| Context-aware configs | ✅ 7000+ facts | ⚠️ Limited | ❌ | ✅ Ohai | ✅ Grains |
| **Community** | | | | | |
| Module ecosystem | ✅ Forge | ✅ Galaxy | ✅ Registry | ❌ Weak | ⚠️ Limited |
| Quality standards | ✅ Strong | ⚠️ Variable | ⚠️ Variable | ⚠️ Weak | ⚠️ Variable |
| Built-in apps | ✅ 60+ | ⚠️ External | ❌ | ⚠️ Limited | ⚠️ Limited |
| **Monitoring** | | | | | |
| Hardware monitoring | ✅ Dell, HP, IBM | ❌ | ❌ | ❌ | ❌ |
| Auto-detect & configure | ✅ Fact-based | ❌ | ❌ | ⚠️ Manual | ⚠️ Manual |
| Prometheus integration | ✅ Built-in | ⚠️ External | ⚠️ External | ⚠️ External | ⚠️ External |
| Grafana dashboards | ✅ Pre-built | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |

### Core Architectural Differences

**Pull Model vs. Push Model:**
- **LinuxAid (Pull):** Systems pull configuration from central server in controlled, auditable manner
- **Ansible (Push):** Administrators SSH into systems and execute commands directly using Python Fabric library
- **Terraform (State File):** Tracks infrastructure in separate state file that must be carefully managed

This architectural decision cascades into every aspect of operational practice.

### The SSH Anti-Pattern Problem

Ansible's architecture makes it easy to develop problematic workflows:

1. **Production SSH access:** "Quick fix" via SSH
2. **Update playbook:** Try to capture the fix in code
3. **Test deployment:** Deploy to fresh system, it fails
4. **Missing steps:** Realize manual fix had undocumented steps
5. **Iterate:** Multiple rounds of SSH + playbook updates
6. **Give up:** Playbook "mostly works" but needs manual intervention

**The problem:** When you have direct SSH access, you risk changes not being logged anywhere, violating compliance requirements and "good way of working" with colleagues. You iterate on fixes, make manual changes, and forget steps.

**LinuxAid's approach:** You don't SSH directly to servers you manage. All changes run through the Puppet server. You must update your configuration code. Next run either succeeds or fails with clear errors. No ambiguity, no forgotten manual steps.

LinuxAid makes it much easier **NOT** to land in these bad habits that come naturally with Ansible's SSH-based model.

### Long-Term Operational Sustainability

**The Real Question:** Will your operational patterns still be sustainable in two years when you're managing thousands of systems with compliance requirements?

| Aspect | Ansible | Terraform | LinuxAid |
|--------|---------|-----------|----------|
| **Small scale** | ✅ Quick start | ✅ Provisioning | ✅ |
| **Large scale** | ⚠️ Needs Tower | ❌ Config mgmt | ✅ Proven |
| **Compliance** | ❌ Manual | ⚠️ Partial | ✅ Built-in |
| **Anti-patterns** | ❌ SSH habits | ✅ N/A | ✅ Prevented |
| **Technical debt** | ❌ Accumulates | ⚠️ State files | ✅ Minimal |
| **Sustainability** | ⚠️ Small teams | ⚠️ Infra only | ✅ Enterprise |

**LinuxAid:**
- Architected for sustainable operations at scale (100s to 100,000s of systems)
- Compliance-friendly workflows naturally support audit requirements
- Change confidence through catalog diffing and dry-run validation
- Prevents anti-patterns through architectural constraints
- Proven at enterprise scale for decades

### Data Ownership & Use Cases

| Feature | LinuxAid | Ansible | Terraform | Chef | SaltStack |
|---------|----------|---------|-----------|------|-----------|
| **Ownership** | | | | | |
| 100% data ownership | ✅ | ✅ | ✅ | ⚠️ Hosted | ✅ |
| Runs on your servers | ✅ | ✅ | ✅ | ⚠️ Optional | ✅ |
| Post-subscription access | ✅ Full | ✅ | ✅ | ❌ Limited | ✅ |
| No vendor lock-in | ✅ | ✅ | ⚠️ Partial | ❌ | ✅ |
| **Best For** | | | | | |
| Small (< 50 servers) | ✅ | ✅ | ⚠️ Provision | ✅ | ✅ |
| Medium (50-1000) | ✅ | ⚠️ | ⚠️ Provision | ✅ | ✅ |
| Enterprise (1000+) | ✅ Proven | ⚠️ Tower | ❌ | ✅ | ✅ |
| Compliance-heavy | ✅ Built-in | ❌ | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |
| Multiple contributors | ✅ GitHub | ⚠️ Difficult | ⚠️ Locking | ⚠️ Difficult | ⚠️ Difficult |
| Infrastructure provision | ⚠️ Terraform | ⚠️ Limited | ✅ Perfect | ⚠️ Limited | ⚠️ Limited |
| System configuration | ✅ Perfect | ⚠️ Small | ❌ Wrong | ✅ | ✅ |

---

## Complementary Tools

**Best Practice:** Use multiple tools for their strengths:

- **Terraform:** Provision infrastructure (cloud resources, networking, load balancers)
- **LinuxAid:** Configure and maintain systems (ongoing compliance, security, applications)
- **Puppet Bolt:** One-off tasks and orchestration (separate tool that can complement LinuxAid)

---

## Key Differentiators

**LinuxAid's Unique Strengths:**

1. **Catalog-diff** - The transformational capability for large-scale operations (no competitor offers this)
2. **Stateless architecture** - No state file management overhead
3. **Built-in compliance** - GDPR, CIS, NIS2 ready out of the box
4. **Supply chain security** - Repository server with GPG signing and air-gap support
5. **Proven architecture at extreme scale** - 100,000+ servers at AWS, eBay and GitHub
6. **Prevents anti-patterns** - Architecture naturally discourages problematic workflows

---

## Docs

* [Guides](./docs/guides)
* [Facts](./docs/facts)
* [Monitoring](./docs/monitoring)
* [Roles](./docs/roles)
* [Setup](./docs/setup)
