path = require 'path'

module.exports =
  config:
    stylintExecutablePath:
      type: 'string'
      default: '/usr/local/bin/stylint'

  activate: ->
    console.log 'activate linter-stylint'
