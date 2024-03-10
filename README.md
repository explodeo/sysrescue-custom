When executing `sysrescue-customize`, run it the following way:
```sh
$ ./sysrescue-customize --auto -s <ISO_FILE> -d ./extracted-iso -r ./recipe-dir -w work-dir -o
```

the `srm-dir` should not be used unless you plan on manually building sysrescue.

the `work-dir` is solely used for processing and should not be touched. feel free to `rm -rf` everything in that directory between builds as the `sysrescue-customize` script only uses it to manage files during runtime.
