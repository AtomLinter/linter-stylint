path = require 'path'

module.exports =
  configDefaults:
    executablePath: path.join __dirname, '..', 'node_modules', 'stylint', 'bin'

  activate: ->
    console.log 'activate linter-stylint'
