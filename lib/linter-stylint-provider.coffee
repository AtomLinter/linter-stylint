path = require 'path'
{BufferedNodeProcess} = require 'atom'
findFile = require '../utils/findFile'
XRegExp = require('xregexp').XRegExp

LinterStylint =

  grammarScopes: ['source.styl', 'source.stylus']

  scope: 'file'

  lintOnFly: true

  lint: (textEditor) ->
    return new Promise (resolve, reject) =>
      results = ''
      messages = []
      filePath = textEditor.getPath()
      regex = XRegExp(
        '((?P<warning>Warning)|(?P<error>Error)):\\s*(?P<message>.+)\\s*' +
        'File:\\s(?P<file>.+)\\s*' +
        'Line:\\s(?P<line>\\d+):\\s*(?P<near>.+\\S)',
        'im'
      )
      configFile = findFile path.dirname(filePath), ['.stylintrc']
      if @config 'onlyRunWhenConfig'
        if configFile == undefined
          console.log 'No stylint config found'
          return resolve []

      params = [filePath]

      if @config 'runWithStrictMode'
        params = params.concat ['-s']
      else
        index = params.indexOf('-s')
        if index > -1
          params.splice(index, 1)
        params = params.concat ['-c', configFile] if configFile

      command = @config 'executablePath'
      args = params
      options = {cwd: path.dirname(filePath)}
      stdout = (data) ->
        results = data
      stderr = (err) ->
        console.log err
      exit = (code) ->
        return resolve [] unless code is 1
        console.log results
        XRegExp.forEach results, regex, (match) =>
          console.log match
          type = if match.error
            "Error"
          else if match.warning
            "Warning"
          messages.push {
            type: type or 'Warning'
            text: match.message
            filePath: match.file or textEditor.getPath()
            range: [
              [match.line - 1, -1],
              [match.line - 1, -1]
            ]
          }
        resolve(messages)

      process = new BufferedNodeProcess({command, args, options,
                                  stdout, stderr, exit})
      process.onWillThrowError ({error,handle}) ->
        atom.notifications.addError "Failed to run #{@config 'executablePath'}",
          detail: "#{error.message}"
          dismissable: true
        handle()
        resolve []

  config: (key) ->
    atom.config.get "linter-stylint.#{key}"

module.exports = LinterStylint
