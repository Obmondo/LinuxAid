# Generate Docs

We use ```puppet strings``` to generate docs for our codebase. We practice 100% documented code therefore each change from you should also update the docs.

After making changes in the codebase, go to ```bin/generate_doc_enableit_module.sh``` and edit MODULES variable accordingly and run the script.

```shell
./bin/generate_doc_enableit_module.sh
```

It will update the ```REFERENCE.md``` file.
