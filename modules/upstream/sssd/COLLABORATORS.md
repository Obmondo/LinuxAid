# How to release this software

1. Bump the version in `metadata.json`

1. Update the `CHANGELOG.md`

1. Update the `REFERENCE.md` by running `bundle exec rake reference`

1. `git commit -am 'Release x.y.z'`

1. `git tag -a 'x.y.z' -m 'x.y.z'`

1. `git push upstream master`

1. `git push upstream --tags`

1. `git checkout gh-pages && bundle exec rake doc && git commit -am
   'Docs for release x.y.z' && git push upstream gh-pages`

Tags will automatically be pushed to the Puppet Forge [sgnl05/sssd](https://forge.puppet.com/sgnl05/sssd)
