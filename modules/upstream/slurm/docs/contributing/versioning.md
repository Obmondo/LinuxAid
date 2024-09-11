The operation consisting of releasing a new version of this repository is
automated by a set of tasks within the `Rakefile`.

In this context, a version number have the following format:

      <major>.<minor>.<patch>

where:

* `< major >` corresponds to the major version number
* `< minor >` corresponds to the minor version number
* `< patch >` corresponds to the patching version number

Example: `1.2.0`

The current version number is stored in the file `metadata.json`.
For more information on the version, run:

     $> rake version:info

If a new  version number such be bumped, you simply have to run:

     $> rake version:bump:{major,minor,patch}

This will start the release process for you using `git-flow`.
Then, to make the release effective, just run:

     $> rake version:release

This will finalize the release using `git-flow`, create the appropriate tag and merge all things the way they should be.
