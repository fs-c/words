In the root of the project:

```
$ chmod +x d/build.sh
$ ./d/build.sh && ./words
```

### Requirements

The [`ldc` compiler](https://github.com/ldc-developers/ldc#installation) and `dub`, the D package manager.

### Performance

On average (over 1000 runs), a dry run (no content) took slightly less than 1ms. Every additional content file added around 1ms, with the testing files having 15kb.