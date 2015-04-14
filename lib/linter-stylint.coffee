{CompositeDisposable} = require 'atom'

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

  executablePath: null

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

    @disposables = new CompositeDisposable

    item = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path

    if filePath
      @cmd = @cmd.concat [filePath]

    config = findFile @cwd, ['.stylintrc']
    @cmd = @cmd.concat ['-c', config] if config

    @disposables.add atom.config.observe 'linter-stylint.stylintExecutablePath', =>
      executablePath = atom.config.get 'linter-stylint.stylintExecutablePath'

      if executablePath
        @executablePath = if executablePath.length > 0 then executablePath else null

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
    @disposables.dispose()

module.exports = LinterStylint
