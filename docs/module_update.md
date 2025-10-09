## Puppet Module update

### Manual Steps
```sh
* ./bin/update_puppetfile.sh
* git add Puppetfile && git commit
* docker run -it  -v $(pwd):/build ubuntu:24.04 /bin/bash
* apt install r10k
* r10k puppetfile install --moduledir modules/upstream
* sudo find modules/upstream -type d  -name .git -exec ls -al {} +
* sudo find modules/upstream -type d  -name .git -exec rm -fr {} +
```
