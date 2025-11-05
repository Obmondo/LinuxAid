# LinuxAid

A platform for everything you need to run a secure and reliable Linux operations setup

## Config options

Under each module that you use in linuxaid-config tree - you can see the documentation for it the corresponding REFERENCE.md file - following the Puppet standard way of documenting modules.

For LinuxAid we have built these modules:

- [Roles](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/role/REFERENCE.md) - the list of roles (software and configs we support currently). Note some roles support mixing - so multiple roles cannot always be assigned to a server, as they can conflict.
- [Common settings](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/common/REFERENCE.md) - the list of common configurations you can rollout for any server, regardless of its configured role.
- [Monitoring settings](https://github.com/Obmondo/LinuxAid/blob/master/modules/enableit/monitor/REFERENCE.md) - settings for monitoring

These options can be applied in different scopes and by default LinuxAid has been built to support applying options based on:

- **Tags** - which is just a group - given by OpenVox ENC. 
  TODO: Document ENC features and custom tag support.
- **Facts** - Which is 'knowledge about a system' and you can define config for any fact, including:
  - OS, Distribution, software versions installed or versions of these
  - Location
  - specific hardware configurations, like which raid controller or how much memory etc.

  We have over 7k facts - and we then filter that down by default to avoid clogging up the database necessary. This filter is adjustable, should you find you want to use some of the facts we've chosen not to use by default. See [Facts](./docs/facts) for details.

### Hierarchical Data Management with Hiera

LinuxAid leverages Hiera's hierarchical data lookup system for sophisticated data separation from code. This builds on the scope-based configuration mentioned above (Tags and Facts), allowing you to organize and override configuration data at any level of specificity.

**Benefits:**
- Same codebase across dev, staging, and production
- Override data at appropriate specificity levels (node, location, OS, etc.) - leveraging the Tag and Fact-based scopes described above
- Clear separation between code logic and environment-specific data
- Similar flexibility to Helm values in Kubernetes

NB. You can see the Hierarchy we've built to support this (and adjust as you want it) here: https://github.com/Obmondo/LinuxAid/blob/master/hiera.yaml#L10

### 60+ Supported Applications

LinuxAid provides out-of-the-box support for 60+ applications, including:
- Web servers (Nginx, Apache, HAProxy)
- Databases (MySQL, PostgreSQL, MongoDB)
- Monitoring tools (Prometheus, Grafana)
- Mail servers (Mailcow)
- VPN solutions (WireGuard)
- And many more

All with pre-configured, production-ready settings that follow best practices.

## Calculate Changes Before Deployment

**One of LinuxAid's most powerful capabilities** is the ability to calculate and preview ALL changes that any code modification will cause across your entire infrastructure, without touching a single server.

### How It Works

When managing 30,000 servers, you can:

1. **Make a code change** in your configuration repository
2. **Calculate changesets** automatically for all nodes
3. **Preview detailed impact** - see exactly what will change on each server
4. **Group by pattern** - reduce 30,000 servers to 5-7 distinct changeset patterns
5. **Review before deployment** - know precisely which servers will be affected and how

### Example Output

Instead of discovering issues after deployment, you get a preview like this:

```
Changeset Pattern 1: (affects 15,234 servers)
  Catalog Changes:
  
  File[/etc/nginx/nginx.conf]:
    parameters:
      ensure: 
        - file
      content:
        - {md5}8f3d5e9a1c2b4e6f (current)
        + {md5}a7b2c9d4e1f6g8h3 (new)
    
  Service[nginx]:
    parameters:
      ensure:
        - running
        + running (restarted)
    dependencies:
      ~> subscribes to File[/etc/nginx/nginx.conf]
  
  Affected servers: web-prod-*, web-staging-*

Changeset Pattern 2: (affects 8,421 servers)
  Catalog Changes:
  
  Package[openssl]:
    parameters:
      ensure:
        - 1.1.1k
        + 1.1.1l
  
  File[/etc/ssl/certs/ca-bundle.crt]:
    parameters:
      ensure:
        - file
      content:
        - {md5}c4d5e6f7g8h9i0j1 (current)
        + {md5}k2l3m4n5o6p7q8r9 (new)
    dependencies:
      <- requires Package[openssl]
  
  Affected servers: all-debian-11-*

Changeset Pattern 3: (affects 3,156 servers)
  No catalog changes
  
  Affected servers: db-primary-*, db-replica-*

Changeset 3: (affects 3,156 servers)
  No changes (catalog identical)
  Servers: db-primary-*, db-replica-*

Changeset 4: (affects 2,891 servers)
  Changes:
  - Firewall[100 allow https]:
      dport: 443
      action: accept
  Servers: lb-*, api-*

Changeset 5: (affects 298 servers)
  Changes:
  - User[deploy]:
      ensure: present
      groups: docker, sudo
  - File[/home/deploy/.ssh/authorized_keys]:
      ensure: file
      content: (new content)
  Servers: app-new-*
```

### Real-World Benefits

**Before making any changes to production, you know:**
- Exactly what will change on each server
- Which servers will be affected
- How many distinct change patterns exist
- Whether your change will have unintended consequences

**Traditional approach (Ansible, manual scripting):**
1. Run playbook against production
2. Discover it changed unexpected systems
3. Roll back manually
4. Debug what went wrong
5. Try again

**LinuxAid approach:**
1. Review changeset calculation
2. See exactly what will change and where
3. Approve or reject before any server is touched
4. Deploy with confidence

This capability is essential when:
- Managing thousands of heterogeneous systems
- Working with multiple contributors on the same codebase
- Meeting compliance requirements that demand change documentation
- Preventing production incidents from untested changes

## Security and Reliability

### Supply Chain Security

LinuxAid provides an [open source repository server](https://gitea.obmondo.com/EnableIT/LinuxAid/src/branch/master/modules/enableit/role/REFERENCE.md#role--package_management--repo) for supply chain security.

**Features:**
- Mirror any upstream repository for air-gapped operations
- Servers don't need internet access to function
- Automatic snapshots for staged rollouts
- Built-in packagesign daemon for GPG signing packages

**Protection Against Single-Point-of-Compromise:**

LinuxAid is designed to protect against any single-point-of-compromise affecting you:

1. **GPG sign all commits** on branches that build packages (easily setup in .gitconfig)
2. **Validate signatures on runners** - runners (separate from and not managed by your Git host) validate ALL GPG signatures before CI jobs run
3. **Protect against compromised Git hosts** - even if attackers inject code, runners won't execute jobs without valid signatures

This way, malicious code cannot sneak into your release packages.

### Staged Rollouts

Using LinuxAid's repository server:
- Enable automatic snapshots (hardlink-based for efficiency)
- Split servers into groups
- Assign snapshots to one group at a time
- Roll out security updates progressively

You can do the same for your LinuxAid configuration (hiera tree) by using git branches or tags and locking servers to specific environments.

### GitOps

LinuxAid was built for centralized management and GitOps:

- **Changelog of everything done on your systems**
  Required by ISO 27001:2022, ITILv4, and regulations worldwide including NIS2.
  TODO: Add links to these requirements (in our upcoming compliance helper)

- **All changes through central server**
  - All changes flow through the central LinuxAid server
  - Complete logging and auditability
  - No direct SSH to systems for "quick fixes"
  - Prevents the anti-pattern of undocumented manual changes

- **Branch-based development and testing**
  - Develop features in feature branches
  - Calculate changes against real systems using branch-specific configurations
  - Merge to main only after validation
  - No need to maintain separate test infrastructure

- **Standardized code review methods for operations**
  Everything's a Pull Request now.

- **Supply Chain Security on operations**
  See the GPG signing feature in the Supply Chain Security section above.

### Compliance Built-In

LinuxAid ensures GDPR, CIS, and NIS2 compliance through its architecture:
- Audit-ready change tracking
- Separation of duties (no production SSH needed)
- Reproducible system states
- Configuration baselines enforcement
- Drift detection and correction

## Monitoring

LinuxAid includes comprehensive monitoring for everything we have needed for any customer, including hardware monitoring for Dell, HP, IBM, Supermicro, and more. We constantly add support and gladly accept PRs!

**Automatic Hardware Detection:**
LinuxAid automatically detects your hardware and system configuration using 'facts' (1000+ available), then configures your server with the appropriate monitoring for your specific hardware and software setup.

**Observability Stack:**
- Prometheus for metrics tracking
- Grafana dashboards (pre-built)
- Alert Manager with custom rules and pre-defined thresholds

### High Availability

LinuxAid runs under a Kubernetes setup (documented in KubeAid) which can be deployed on:
- Single-host Linux server
- Multi-node high availability cluster
- Any cloud provider or on-premises

**Scalable Architecture:** The OpenVox Server is written in Clojure with workload separation:
- **Compiler:** Builds configurations (CPU-intensive work)
- **API Layer:** Handles agent communications
- **Independent scaling:** Scale components based on workload

See technical details on [monitoring here](https://github.com/Obmondo/LinuxAid/blob/master/docs/monitoring/monitoring.md)

## Proven at Enterprise Scale

The architecture LinuxAid is built on has been proven at massive scale:

- **Puppet Enterprise:** The upstream project officially documents support for 20,000+ nodes with compile masters
- **Large enterprise deployments:** Organizations have successfully deployed Puppet at scales reaching 100,000+ servers
- **GitHub:** Manages thousands of nodes with extensive Puppet code (500,000+ lines) and 200+ contributors
- **Financial institutions:** Major banks have deployed this architecture for 30,000+ servers in highly regulated environments

These organizations chose this architecture because alternative approaches **don't scale operationally**. The ability to calculate changes across tens of thousands of heterogeneous systems with hundreds of contributors becomes essential at this scale.

**LinuxAid provides this same proven architecture** through OpenVox with years of Obmondo's expertise, delivering 60+ supported applications, built-in compliance frameworks (GDPR, CIS, NIS2), and enterprise-grade monitoring out of the box.

## 100% Data Ownership

LinuxAid provides true data ownership:
- Your setup runs on your servers
- Infrastructure code remains on your systems
- Full control even after subscription ends
- No vendor lock-in
- Can be hosted on-premises or in any cloud

---

## How LinuxAid Compares to Alternatives

While other tools have their place, LinuxAid provides an integrated approach that addresses operational challenges at scale and in compliance-sensitive environments.

### Core Infrastructure Management

| Feature | LinuxAid (OpenVox) | Ansible | Terraform | Chef | SaltStack |
|---------|----------|---------|-----------|------|-----------|
| **State Management** | | | | | |
| Stateless (no state files) | ✅ | ✅ | ❌ | ✅ | ✅ |
| Automatic drift detection | ✅ | ⚠️ Limited | ⚠️ Manual refresh | ✅ | ✅ |
| Dynamic system querying | ✅ Via OpenVoxDB | ⚠️ Via inventory | ❌ | ✅ | ✅ |
| State file corruption risk | ✅ None | ✅ None | ❌ High | ✅ None | ✅ None |
| **Change Management** | | | | | |
| Preview changes before deployment | ✅ noop mode | ⚠️ check mode | ✅ terraform plan | ✅ why-run | ✅ test mode |
| Calculate changes across all systems | ✅ With OpenVoxDB | ⚠️ Requires AWX | ⚠️ Per workspace | ⚠️ Limited | ⚠️ Limited |
| Group similar changes across nodes | ✅ LinuxAid feature | ❌ | ❌ | ❌ | ❌ |
| CI/CD integration for change preview | ✅ | ⚠️ Via AWX/Tower | ✅ | ⚠️ Limited | ⚠️ Limited |
| **Validation & Safety** | | | | | |
| Dry-run capability | ✅ noop mode | ✅ check mode | ✅ plan | ✅ why-run | ✅ test |
| Automatic file backups | ✅ Built-in filebucket | ⚠️ Per-module | ❌ | ⚠️ Manual | ⚠️ Manual |
| Built-in rollback capability | ✅ Via filebucket | ⚠️ Manual playbooks | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |
| **Architecture** | | | | | |
| Pull-based model | ✅ | ❌ Push | ❌ API-driven | ✅ | ✅ Both |
| No production SSH required | ✅ | ❌ Requires SSH | ✅ | ✅ | ✅ |
| Declarative resources | ✅ | ⚠️ Mostly procedural | ✅ Infrastructure only | ✅ | ✅ |
| Automatic dependency resolution | ✅ Graph-based | ❌ Sequential execution | ✅ Limited | ✅ | ⚠️ Limited |
| Define resources in any order | ✅ | ❌ Order matters | ⚠️ Limited | ✅ | ⚠️ Limited |

**Legend:** ✅ Full support | ⚠️ Partial/Requires setup | ❌ Not supported or not applicable

**Notes on change management:**
- All tools listed have dry-run/preview capabilities, but with different levels of completeness
- OpenVox's noop mode (used by LinuxAid) can have limitations with dependent resources
- Ansible's check mode may not catch all changes, especially in conditional tasks
- Terraform's plan is comprehensive for infrastructure but doesn't manage OS-level configuration
- LinuxAid's grouping of changes across nodes into patterns is a custom enhancement

### Compliance & Security Comparison

| Feature | LinuxAid | Ansible | Terraform | Chef | SaltStack |
|---------|----------|---------|-----------|------|-----------|
| **Compliance Frameworks** | | | | | |
| Pre-built compliance policies | ✅ Built-in | ✅ Ansible Lockdown | ⚠️ Limited | ✅ Chef InSpec | ⚠️ External |
| CIS benchmark support | ✅ Integrated | ✅ Via roles | ⚠️ Manual | ✅ Certified | ⚠️ Community |
| DISA STIG support | ✅ | ✅ Via roles | ⚠️ Manual | ✅ Certified | ⚠️ Community |
| Compliance as code | ✅ | ✅ | ⚠️ Limited | ✅ InSpec | ⚠️ Limited |
| **Audit & Reporting** | | | | | |
| Complete audit trail | ✅ OpenVoxDB logs | ✅ Via AWX | ⚠️ State changes | ✅ Chef Automate | ⚠️ Requires setup |
| Compliance reporting | ✅ Built-in | ✅ Via AWX | ⚠️ Limited | ✅ Chef Compliance | ⚠️ Manual |
| Continuous compliance monitoring | ✅ | ✅ Scheduled runs | ❌ | ✅ | ✅ |
| **GitOps & Change Control** | | | | | |
| GitOps native | ✅ | ✅ With tooling | ✅ | ✅ | ⚠️ With tooling |
| All changes logged | ✅ Automatic | ✅ Via AWX/Tower | ⚠️ State logs | ✅ Via Automate | ⚠️ Requires setup |
| Separation of duties | ✅ Built-in | ✅ Via AWX RBAC | ⚠️ Manual | ✅ RBAC | ⚠️ Manual |
| Branch-based environments | ✅ Native | ✅ Manual setup | ✅ Workspaces | ✅ | ⚠️ Manual |
| **Supply Chain Security** | | | | | |
| Repository server | ✅ Built-in role | ❌ | ❌ | ❌ | ❌ |
| Air-gapped operation | ✅ Native support | ⚠️ Manual setup | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |
| GPG signature validation | ✅ Built-in | ⚠️ Manual setup | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |
| Package signing daemon | ✅ Packagesign | ❌ | ❌ | ❌ | ❌ |
| Staged rollouts via snapshots | ✅ Built-in | ⚠️ Manual processes | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |

**Important context:**
- **Ansible:** AWX/Automation Platform (formerly Ansible Tower - note that AWX is the open-source upstream project) provides robust compliance features including audit trails, RBAC, and scheduled compliance checks. Ansible Lockdown project provides well-maintained CIS and STIG roles.
- **Chef:** Chef InSpec is a mature, purpose-built compliance automation tool with CIS certifications and DISA STIG support. Chef Compliance provides comprehensive audit and remediation.
- **Terraform:** Primarily designed for infrastructure provisioning, not OS-level compliance management.
- **SaltStack:** Has compliance capabilities but often requires additional configuration or community modules.

### Scale & Performance Comparison

| Feature | LinuxAid | Ansible | Terraform | Chef | SaltStack |
|---------|----------|---------|-----------|------|-----------|
| **Proven Scale** | | | | | |
| 20,000+ nodes | ✅ Documented | ✅ Via AWX | ⚠️ Not typical use | ✅ Documented | ✅ |
| 100,000+ nodes | ✅ Possible | ✅ AWX designed for this | ❌ Not typical | ✅ Documented | ✅ Documented |
| Large team collaboration | ✅ Proven | ⚠️ Requires AWX | ⚠️ State locking | ✅ | ⚠️ Requires setup |
| Large codebase management | ✅ Proven | ⚠️ Can be challenging | ⚠️ Module-based | ✅ | ⚠️ Variable |
| **Performance** | | | | | |
| Horizontal scaling | ✅ Compile masters | ✅ AWX clusters | ⚠️ Limited | ✅ | ✅ |
| Component-level scaling | ✅ Compiler/API separate | ⚠️ AWX components | ❌ | ✅ | ✅ |
| Efficient agent model | ✅ | ❌ Agentless (SSH) | ❌ API-based | ✅ | ✅ |

**Scale context:**
- **OpenVox:** Based on Puppet architecture which officially documents support for 20,000+ nodes with compile masters, and larger deployments are possible with database separation
- **Ansible AWX:** Designed to manage large numbers of servers according to documentation
- **GitHub's deployment:** Manages thousands of nodes with extensive Puppet infrastructure
- **Enterprise deployments:** Organizations across various industries have successfully deployed Puppet-based systems at enterprise scale

### Application Support & Monitoring

| Feature | LinuxAid | Ansible | Terraform | Chef | SaltStack |
|---------|----------|---------|-----------|------|-----------|
| **Pre-built Application Support** | | | | | |
| Built-in apps (out of box) | ✅ 60+ documented | ✅ Galaxy roles (1000s) | ❌ | ✅ Supermarket | ✅ Community |
| Production-ready configs | ✅ Obmondo tested | ⚠️ Variable quality | N/A | ⚠️ Variable | ⚠️ Variable |
| Integrated approach | ✅ Single platform | ⚠️ Role-based | ⚠️ Provisioning only | ⚠️ Cookbook-based | ⚠️ State-based |
| **Data Management** | | | | | |
| Hierarchical data (Hiera/Pillar) | ✅ Hiera native | ⚠️ group_vars/host_vars | ⚠️ Variables/locals | ⚠️ Data bags | ✅ Pillar |
| Code/data separation | ✅ Excellent | ⚠️ Basic | ⚠️ Basic | ✅ Good | ✅ Good |
| Environment-specific overrides | ✅ Hiera hierarchy | ⚠️ Inventory structure | ⚠️ Workspaces | ✅ Environments | ✅ Pillar |
| Context-aware configs | ✅ 7000+ facts | ✅ gather_facts | ⚠️ Data sources | ✅ Ohai | ✅ Grains |
| **Monitoring** | | | | | |
| Hardware monitoring included | ✅ Multi-vendor | ⚠️ Via roles | ❌ | ⚠️ Via cookbooks | ⚠️ Via states |
| Auto-detect & configure | ✅ Fact-based | ⚠️ Manual setup | ❌ | ⚠️ Requires setup | ⚠️ Requires setup |
| Prometheus integration | ✅ Built-in | ⚠️ Via roles | ⚠️ Provision only | ⚠️ Via cookbooks | ⚠️ Via states |
| Pre-built dashboards | ✅ Grafana included | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual | ⚠️ Manual |

**Application support context:**
- **LinuxAid:** 60+ applications with pre-configured, production-ready settings maintained by Obmondo
- **Ansible:** Ansible Galaxy has thousands of roles, but quality and maintenance vary significantly
- **Chef:** Chef Supermarket provides cookbooks, but like Ansible Galaxy, quality varies
- **Integration:** LinuxAid provides an integrated monitoring stack; other tools require assembling components

### Data Ownership & Use Cases

| Feature | LinuxAid | Ansible | Terraform | Chef | SaltStack |
|---------|----------|---------|-----------|------|-----------|
| **Ownership** | | | | | |
| 100% data ownership | ✅ | ✅ | ✅ | ✅ Open source | ✅ |
| Runs on your infrastructure | ✅ | ✅ | ✅ | ✅ | ✅ |
| Post-subscription access | ✅ Full code access | ✅ | ✅ | ✅ Community version | ✅ |
| No vendor lock-in | ✅ Open source base | ✅ | ⚠️ HCL language | ⚠️ With Enterprise | ✅ |
| **Best Use Cases** | | | | | |
| Small deployments (< 50) | ✅ May be overpowered | ✅ Excellent | ⚠️ Provisioning | ✅ | ✅ |
| Medium scale (50-1000) | ✅ Sweet spot | ✅ Works well | ⚠️ Provisioning | ✅ | ✅ |
| Enterprise (1000+) | ✅ Designed for this | ✅ Requires AWX | ❌ Not typical | ✅ | ✅ |
| Compliance-heavy environments | ✅ Built-in frameworks | ✅ Via Lockdown/AWX | ⚠️ Manual | ✅ InSpec/Compliance | ⚠️ Requires work |
| Multi-team collaboration | ✅ Proven at scale | ⚠️ Needs AWX/structure | ⚠️ State locking issues | ✅ | ⚠️ Requires structure |
| Infrastructure provisioning | ⚠️ Use Terraform | ⚠️ Limited capabilities | ✅ Purpose-built | ⚠️ Limited | ⚠️ Limited |
| System configuration | ✅ Purpose-built | ✅ Good for small-medium | ❌ Wrong tool | ✅ Purpose-built | ✅ Purpose-built |

---

## Key Differentiators

**What Makes LinuxAid Unique:**

1. **Integrated compliance and operations** - Pre-built GDPR, CIS, and NIS2 configurations combined with 60+ supported applications in one platform

2. **Change calculation and preview** - Enhanced OpenVoxDB integration allows previewing changes across infrastructure and grouping similar changes into patterns

3. **Supply chain security** - Built-in repository server with GPG signing, air-gap support, and packagesign daemon for secure package management

4. **Production-ready application support** - 60+ applications with Obmondo-tested, production-ready configurations, not just generic templates

5. **Built on proven technology** - Based on OpenVox (Puppet-compatible), proven at enterprise scale with documented support for 20,000+ nodes and capability for larger deployments

6. **True data ownership** - Open-source foundation means full control even after subscription ends

7. **Integrated monitoring stack** - Hardware-aware monitoring with Prometheus, Grafana, and AlertManager configured out of the box

**Important notes:**
- Many features are based on Puppet/PuppetDB concepts enhanced by Obmondo's OpenVox implementation and years of operational experience
- Competitors like Ansible (with AWX) and Chef (with InSpec/Compliance) have robust compliance and audit capabilities
- The grouping of servers into changeset patterns and preview capabilities are LinuxAid-specific enhancements

---

## Complementary Tools

**Best Practice:** Use the right tool for each job:

- **Terraform:** Provision infrastructure (cloud resources, networking, load balancers)
- **LinuxAid (OpenVox-based):** Configure and maintain systems (ongoing compliance, security, applications, monitoring)
- **Ansible:** Ad-hoc tasks, orchestration (can complement LinuxAid via Bolt)
- **Chef InSpec:** Dedicated compliance auditing (can complement any configuration tool)

---

## The Operational Maturity Question

**The Real Question:** Will your operational patterns scale sustainably when managing hundreds or thousands of systems with compliance requirements?

| Consideration | Ansible | Terraform | LinuxAid (OpenVox) | Chef | SaltStack |
|---------------|---------|-----------|-------------------|------|-----------|
| **Small scale (< 50)** | ✅ Quick & simple | ✅ Provisioning | ⚠️ May be complex | ⚠️ Learning curve | ⚠️ Learning curve |
| **Medium scale (50-1000)** | ✅ With discipline | ⚠️ Infra only | ✅ Designed for this | ✅ Designed for this | ✅ Works well |
| **Large scale (1000+)** | ✅ Needs AWX | ❌ Wrong tool | ✅ Proven | ✅ Proven | ✅ Proven |
| **Compliance requirements** | ✅ Via Lockdown/AWX | ⚠️ Limited | ✅ Built-in | ✅ InSpec | ⚠️ Requires work |
| **Anti-pattern prevention** | ⚠️ Requires discipline | ✅ Declarative | ✅ Architecture enforces | ✅ Architecture enforces | ✅ Architecture enforces |
| **Change confidence** | ✅ check mode + AWX | ✅ plan (infra only) | ✅ noop + OpenVoxDB | ✅ why-run | ✅ test mode |
| **Multi-team collaboration** | ✅ With AWX | ⚠️ State locking | ✅ Designed for it | ✅ Designed for it | ⚠️ Requires setup |

**LinuxAid advantages:**
- Built on OpenVox architecture with documented support for enterprise scale
- Compliance-friendly workflows naturally support audit requirements via OpenVoxDB logging
- Change confidence through noop mode and OpenVoxDB-enhanced change calculation
- Prevents SSH-based anti-patterns through pull-based architecture
- 60+ applications with production-ready configurations from Obmondo's operational experience

### The SSH Anti-Pattern Problem

Ansible's architecture makes it easy to develop problematic workflows:

1. **Production SSH access:** "Quick fix" via SSH
2. **Update playbook:** Try to capture the fix in code
3. **Test deployment:** Deploy to fresh system, it fails
4. **Missing steps:** Realize manual fix had undocumented steps
5. **Iterate:** Multiple rounds of SSH + playbook updates
6. **Give up:** Playbook "mostly works" but needs manual intervention

**The problem:** When you have direct SSH access, changes risk not being logged anywhere, violating compliance requirements and "good way of working" with colleagues. You iterate on fixes, make manual changes, and forget steps.

**LinuxAid's approach:** No direct SSH to managed servers. All changes run through the central server. You must update your configuration code. Next run either succeeds or fails with clear errors. No ambiguity, no forgotten manual steps.

---

## Docs

* [Guides](./docs/guides)
* [Facts](./docs/facts)
* [Monitoring](./docs/monitoring)
* [Roles](./docs/roles)
* [Setup](./docs/setup)
