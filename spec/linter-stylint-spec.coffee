path = require('path')

describe 'The stylint provider for Linter', ->
  lint = require('../lib/init').provideLinter().lint

  beforeEach ->
    atom.workspace.destroyActivePaneItem()
    waitsForPromise ->
       atom.packages.activatePackage('linter-stylint')


  it 'should be in the packages list', ->
     expect(atom.packages.isPackageLoaded('linter-stylint')).toBe true

  it 'should be an active package', ->
     expect(atom.packages.isPackageActive('linter-stylint')).toBe true


  it 'finds nothing wrong with valid file', ->
    waitsForPromise ->
      atom.workspace.open(path.join(__dirname, 'fixtures', 'good.styl')).then (editor) ->
        lint(editor).then (messages) ->
          expect(messages.length).toEqual 0

  it 'finds something wrong with invalid file', ->
    waitsForPromise ->
      atom.workspace.open(path.join(__dirname, 'fixtures', 'bad.styl')).then (editor) ->
        lint(editor).then (messages) ->
          expect(messages.length).toEqual 2
          expect(messages[0].type).toBeDefined()
          expect(messages[0].type).toEqual 'Warning'
          expect(messages[0].text).toBeDefined()
          expect(messages[0].text).toEqual 'unecessary bracket'
          expect(messages[0].filePath).toBeDefined()
          expect(messages[0].filePath).toMatch(/.+bad\.styl$/)
          expect(messages[0].range).toBeDefined()
          expect(messages[0].range.length).toBeDefined()
          expect(messages[0].range.length).toEqual(2)
          expect(messages[0].range).toEqual([[1, 0], [1, 7]])
