path = require 'path'
{CompositeDisposable} = require 'atom'
LinterStylintProvider = require './linter-stylint-provider'

module.exports =
  config:
    executablePath:
      type: 'string'
      title: 'Stylint Executable Path'
      default: '/usr/local/bin/stylint'

    runWithStrictMode:
      default: false
      title: 'Always run Stylint in \'strict mode\' (no config is needed)'
      type: 'boolean'

    onlyRunWhenConfig:
      default: false
      title: 'Only run Stylint if `.stylintrc` is found'
      type: 'boolean'

  activate: ->
    console.log 'activate linter-stylint'

    require('atom-package-deps').install 'linter-stylint'

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-stylint.executablePath',
    (executablePath) =>
      @executablePath = executablePath

    @subscriptions.add atom.config.observe 'linter-stylint.runWithStrictMode',
    (runWithStrictMode) =>
      @runWithStrictMode = runWithStrictMode

    @subscriptions.add atom.config.observe 'linter-stylint.onlyRunWhenConfig',
    (onlyRunWhenConfig) =>
      @onlyRunWhenConfig = onlyRunWhenConfig

  deactivate: ->
    @subscriptions.dispose()

  provideLinter: -> LinterStylintProvider
