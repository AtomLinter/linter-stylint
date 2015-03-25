Atom linter-stylint
=========================

This linter plugin for [Linter](https://github.com/AtomLinter/Linter) provides an interface to [stylint](https://www.npmjs.com/package/stylint). It will be used with files that have the “Stylus” syntax.

## Installation
Linter package must be installed in order to use this plugin. If Linter is not installed, please follow the instructions [here](https://github.com/AtomLinter/Linter).

### Plugin installation
```
$ apm install linter-stylint
```

## Settings
You can configure linter-stylint by editing ~/.atom/config.cson (choose Open Your Config in Atom menu):
```
'linter-stylint':
  'stylintExecutablePath': null #stylint path. run 'which stylint' to find the path
```

## Contributing
If you would like to contribute enhancements or fixes, please do the following:

1. Fork the plugin repository.
2. Hack on a separate topic branch created from the latest `master`.
3. Commit and push the topic branch.
4. Make a pull request.
