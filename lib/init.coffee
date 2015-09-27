helpers = require('atom-linter')
XRegExp = require('xregexp').XRegExp

module.exports =
  config:
    executablePath:
      type: 'string'
      default: path.join __dirname, '..', 'node_modules', 'stylint', 'bin', 'stylint'
      description: 'Full path to binary (e.g. /usr/local/bin/stylint)'

    projectConfigFile:
      type: 'string'
      default: '.stylintrc'
      description: 'Relative path from project to config file'

    runWithStrictMode:
      default: false
      title: 'Always run Stylint in \'strict mode\' (config no needed)'
      type: 'boolean'

    onlyRunWhenConfig:
      default: false
      title: 'Run Stylint only if config is found'
      type: 'boolean'

  activate: ->
    require('atom-package-deps').install 'linter-stylint'

  provideLinter: ->
    provider =
      grammarScopes: ['source.stylus', 'source.styl']
      scope: 'file'
      lintOnFly: true

      config: (key) ->
        atom.config.get "linter-stylint.#{key}"

      lint: (textEditor) ->
        filePath = textEditor.getPath()
        fileText = textEditor.getText()

        onlyRunWhenConfig = @config 'onlyRunWhenConfig'
        runWithStrictMode = @config 'runWithStrictMode'
        executablePath = @config 'executablePath'
        projectConfigFile = @config 'projectConfigFile'

        projectConfigPath = helpers.findFile(atom.project.getPaths()[0], projectConfigFile)

        parameters = []
        parameters.push(filePath)

        if(onlyRunWhenConfig && !projectConfigPath)
          console.log 'Stylint config no found'
          return

        if(onlyRunWhenConfig || !runWithStrictMode && projectConfigPath)
          parameters.push('-c', projectConfigPath)

        return helpers.execNode(executablePath, parameters, stdin: fileText).then (result) ->
          toReturn = []
          regex = XRegExp(
            '((?P<warning>Warning)|(?P<error>Error)):\\s*(?P<message>.+)\\s*' +
            'File:\\s(?P<file>.+)\\s*' +
            'Line:\\s(?P<line>\\d+):\\s*(?P<near>.+\\S)',
            'im'
          )
          XRegExp.forEach result, regex, (match) ->
            type = if match.error
              'Error'
            else
              'Warning'

            toReturn.push {
              type: type
              text: match.message
              filePath: match.file
              range: [
                [match.line - 1, -1],
                [match.line - 1, -1]
              ]
            }
          return toReturn
