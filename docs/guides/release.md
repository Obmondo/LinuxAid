## LinuxAid Release

1. Run the release script
  * This will create a new tag and push it to required upstream
  * Run from master branch only, otherwise it will fail
  * This will also updated the openvox agent environment
  * Update the changelog.md as well
  * Gorelease will update the release notes as well

```bash
bin/release.sh <new-tag>
```
