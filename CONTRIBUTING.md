# Contributing to LinuxAid

We welcome pull requests that improve LinuxAid docs, modules, tooling, or workflows. This guide explains the GitHub workflow we expect contributors to follow.

## Before You Start

- Confirm you are familiar with Git, GitHub, and your local development environment. There are plenty of good tutorials available on the internet. Here's one to get started - https://www.atlassian.com/git
- Read `README.md` to understand the project structure and coding conventions that way you understand the project better.
- Look through open issues and pull requests to avoid duplicating existing work.
- Before proceeding to implement any feature, open up an issue and tag repo mastertainers so that they can give you their insights.

## Standard GitHub Workflow

1. **Fork the repository** to your GitHub account.
2. **Clone your fork** locally: `git clone git@github.com:<your_username>/LinuxAid.git`.
3. **Add the upstream remote** so you can pull the latest changes:
   - `git remote add upstream git@github.com:Obmondo/LinuxAid.git`
4. **Create a feature branch** from `master` before editing files:
   - `git checkout -b feature/<branchName>`
5. **Keep your branch current** by syncing with upstream regularly:
   - `git fetch upstream`
   - `git rebase upstream/master`

## Making Changes

- Follow the style and structure of the files you modify.
- Keep each branch focused on a single concern; start another branch if you uncover unrelated work.
- Update documentation or tests when your change affects them.
- Run relevant checks (linters, unit tests, docs builds) before committing.
- Commit early, but consider squashing or cleaning up commits before opening a pull request if it improves clarity.

## Commit Practices

- Use descriptive commit messages that explain the motivation for each change.
- Reference related issues or discussions when helpful.
- Avoid committing generated files or local environment artifacts.

## Protection Against Single-Point-of-Compromise

LinuxAid is designed to protect against any single-point-of-compromise affecting you:

1. **GPG sign all commits** on branches that build packages (easily setup in .gitconfig)
2. **Validate signatures on runners** - runners (separate from and not managed by your Git host) validate ALL GPG signatures before CI jobs run
3. **Protect against compromised Git hosts** - even if attackers inject code, runners won't execute jobs without valid signatures

This way, malicious code cannot sneak into your release packages.

## Opening a Pull Request

- Push your feature branch to your fork: `git push origin feature/<branchName>`.
- Open a pull request against `Obmondo/LinuxAid:master`.
- Fill in the pull request template or clearly describe:
  - What changed and why
  - How you tested the change
  - Any follow-up work that remasters
- Be responsive to code review feedback and make follow-up commits as needed.

## After Merge

- Pull the updated `master` branch from upstream so your local environment stays current.
- Delete merged branches locally and on your fork to keep things organized.

Thanks for contributing to LinuxAid! Your improvements help everyone who relies on this project.
