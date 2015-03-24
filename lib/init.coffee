path = require 'path'

module.exports =
  configDefaults:
    stylintExecutablePath: path.join __dirname, '..', 'node_modules', 'stylint', 'bin'

  activate: ->
    console.log 'activate linter-stylint'
