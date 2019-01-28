'use babel';

import path from 'path';

const multiPath = path.join(__dirname, 'fixtures', 'multi', 'multi.styl');
const noConfigMultiPath = path.join(__dirname, 'fixtures', 'no-config-multi', 'multi.styl');
const goodPath = path.join(__dirname, 'fixtures', 'good', 'good.styl');
const errorPath = path.join(__dirname, 'fixtures', 'error', 'error.styl');
const reporterPath = path.join(__dirname, 'fixtures', 'custom-reporter', 'reporter.styl');

const validateMulti = (messages, filePath) => {
  expect(messages.length).toBe(3);

  expect(messages[0].severity).toBe('warning');
  expect(messages[0].excerpt).toBe('unnecessary bracket (brackets)');
  expect(messages[0].url).not.toBeDefined();
  expect(messages[0].location.file).toBe(filePath);
  expect(messages[0].location.position).toEqual([[0, 5], [0, 7]]);

  expect(messages[1].severity).toBe('warning');
  expect(messages[1].excerpt).toBe('missing colon between property and value (colons)');
  expect(messages[1].url).not.toBeDefined();
  expect(messages[1].location.file).toBe(filePath);
  expect(messages[1].location.position).toEqual([[1, 4], [1, 7]]);

  expect(messages[2].severity).toBe('warning');
  expect(messages[2].excerpt).toBe('unnecessary bracket (brackets)');
  expect(messages[2].url).not.toBeDefined();
  expect(messages[2].location.file).toBe(filePath);
  expect(messages[2].location.position).toEqual([[2, 0], [2, 1]]);
};

const validateError = (messages, filePath) => {
  expect(messages.length).toEqual(1);
  expect(messages[0].severity).toBe('error');
  expect(messages[0].excerpt).toBe('unnecessary colon found (colons)');
  expect(messages[0].url).not.toBeDefined();
  expect(messages[0].location.file).toBe(filePath);
  expect(messages[0].location.position).toEqual([[1, 6], [1, 7]]);
};

describe('The stylint provider for Linter', () => {
  const { lint } = require('../lib/init.js').provideLinter();

  beforeEach(() => {
    atom.workspace.destroyActivePaneItem();
    waitsForPromise(() => atom.packages.activatePackage('linter-stylint'));
  });

  it('should be in the packages list', () => (
    expect(atom.packages.isPackageLoaded('linter-stylint')).toBe(true)
  ));

  it('should be an active package', () => (
    expect(atom.packages.isPackageActive('linter-stylint')).toBe(true)
  ));

  it('finds nothing wrong with valid file', () => (
    waitsForPromise(() => (
      atom.workspace.open(goodPath).then(editor => (
        lint(editor).then(messages => expect(messages.length).toBe(0))
      ))
    ))
  ));

  describe('checks a file with multiple issues', () => {
    it('works with a config', () => (
      waitsForPromise(() => (
        atom.workspace.open(multiPath).then(editor => (
          lint(editor).then(messages => validateMulti(messages, multiPath))
        ))
      ))
    ));

    it('works without a config', () => (
      waitsForPromise(() => (
        atom.workspace.open(noConfigMultiPath).then(editor => (
          lint(editor).then(messages => validateMulti(messages, noConfigMultiPath))
        ))
      ))
    ));
  });

  it('works when custom reporters are specified in the configuration', () => (
    waitsForPromise(() => (
      atom.workspace.open(reporterPath).then(editor => (
        lint(editor).then(messages => validateError(messages, reporterPath))
      ))
    ))
  ));

  it('handles error-level severity', () => (
    waitsForPromise(() => (
      atom.workspace.open(errorPath).then(editor => (
        lint(editor).then(messages => validateError(messages, errorPath))
      ))
    ))
  ));
});
