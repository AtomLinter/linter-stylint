linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
{findFile, warn} = require "#{linterPath}/lib/utils"

class LinterStylint extends Linter
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  @syntax: ['source.stylus']

  # A string, list, tuple or callable that returns a string, list or tuple,
  # containing the command line (with arguments) used to lint.
  cmd: ['stylint']

  linterName: 'stylint'

  # A regex pattern used to extract information from the executable's output.
  regex:
    '/^((?P<warning>Warning)|(?P<error>Error)):\s*(?P<message>.+)\s*'+
    '^.*\s*' +
    'Line:\s*(?P<line>\d+):\s*(?P<near>.*\S)/im'

  isNodeExecutable: yes
  multiline: yes

  constructor: (editor) ->
    super(editor)

    config = findFile @cwd, ['.stylintrc']
    if config
      @cmd = @cmd.concat ['--config', config]

    atom.config.observe 'linter-stylint.stylintExecutablePath', @formatShellCmd

  formatShellCmd: =>
    stylintExecutablePath = atom.config.get 'linter-stylint.stylintExecutablePath'
    @executablePath = "#{stylintExecutablePath}"

  formatMessage: (match) ->
    type = if match.error
      "Error"
    else if match.warning
      "Warning"
    else
      warn "Regex does not match lint output", match
      ""

    "#{match.message} (#{type}#{match.line}#{match.near})"

  destroy: ->
    atom.config.unobserve 'linter-stylint.stylintExecutablePath'

module.exports = LinterStylint
