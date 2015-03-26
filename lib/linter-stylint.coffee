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
  # ((?P<warning>Warning)|(?P<fail>Error)):\s*(?P<message>.+)\s*.*\s*Line:\s*(?P<line>\d+):\s*(?P<near>.*\S)
  regex:
    '((?P<warning>Warning)|(?P<error>Error)):\\s*(?P<message>.+)\\s*'+
    'File:\\s(?P<file>.+)\\s*' +
    'Line:\\s(?P<line>\\d+):\\s*(?P<near>.+\\S)'
  regexFlags: 'im'

  isNodeExecutable: yes

  constructor: (editor) ->
    super(editor)

    item = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path

    if filePath
      @cmd = @cmd.concat [filePath]

    config = findFile @cwd, ['.stylintrc']
    if config
      @cmd = @cmd.concat ['--config', config]

    atom.config.observe 'linter-stylint.executablePath', @formatShellCmd

  formatShellCmd: =>
    executablePath = atom.config.get 'linter-stylint.executablePath'
    @executablePath = "#{executablePath}"

  formatMessage: (match) ->
    type = if match.error
      "Error"
    else if match.warning
      "Warning"
    else
      warn "Regex does not match lint output", match
      ""

    "#{match.message} (#{type}: #{match.line} #{match.near})"

  destroy: ->
    atom.config.unobserve 'linter-stylint.executablePath'

module.exports = LinterStylint
