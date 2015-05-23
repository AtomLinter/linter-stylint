path = require 'path'

module.exports =
  config:
    stylintExecutablePath:
      type: 'string'
      title: 'Stylint Executable Path'
      default: '/usr/local/bin/stylint'

    runWithStrictMode:
      default: false
      title: 'Always run Stylint in \'strict mode\' (no config is needed).'
      type: 'boolean'

  activate: ->
    console.log 'activate linter-stylint'
