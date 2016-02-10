{CompositeDisposable} = require('atom')
path = require('path')

module.exports =
  config:
    executablePath:
      type: 'string'
      default: path.join __dirname, '..', 'node_modules', 'stylint', 'bin', 'stylint'
      description: 'Full path to the `stylint` executable node script file (e.g. /usr/local/bin/stylint)'

    projectConfigFile:
      type: 'string'
      default: '.stylintrc'
      description: 'Relative path from project to config file'

    runWithStrictMode:
      default: false
      title: 'Always run Stylint in \'strict mode\' (Config not necessary)'
      type: 'boolean'

    onlyRunWhenConfig:
      default: false
      title: 'Run Stylint only if config is found'
      type: 'boolean'

  activate: ->
    require('atom-package-deps').install()
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-stylint.executablePath',
      (executablePath) =>
        @executablePath = executablePath
    @subscriptions.add atom.config.observe 'linter-stylint.projectConfigFile',
      (projectConfigFile) =>
        @projectConfigFile = projectConfigFile
    @subscriptions.add atom.config.observe 'linter-stylint.runWithStrictMode',
      (runWithStrictMode) =>
        @runWithStrictMode = runWithStrictMode
    @subscriptions.add atom.config.observe 'linter-stylint.onlyRunWhenConfig',
      (onlyRunWhenConfig) =>
        @onlyRunWhenConfig = onlyRunWhenConfig

  provideLinter: ->
    helpers = require('atom-linter')
    provider =
      grammarScopes: ['source.stylus', 'source.styl', 'source.css.styl', 'source.css.stylus']
      scope: 'file'
      lintOnFly: true

      lint: (textEditor) =>
        filePath = textEditor.getPath()
        fileText = textEditor.getText()

        if !fileText
          return Promise.resolve([])

        projectConfigPath = helpers.find(filePath, @projectConfigFile)

        parameters = [filePath]

        if(@onlyRunWhenConfig && !projectConfigPath)
          atom.notifications.addError 'Stylint config no found'
          return Promise.resolve([])

        if(@onlyRunWhenConfig || !@runWithStrictMode && projectConfigPath)
          parameters.push('-c', projectConfigPath)

        return helpers.execNode(@executablePath, parameters, stdin: fileText).then (result) ->
          regex = /(Warning|Error):\s(.*)\nFile:\s(.*)\nLine:\s(\d*)/g
          messages = []

          while (match = regex.exec(result)) != null
            messages.push
              type: match[1]
              text: match[2]
              filePath: match[3]
              range: helpers.rangeFromLineNumber(textEditor, match[4] - 1)

          return messages
