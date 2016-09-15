'use babel';

import path from 'path';

const badPath = path.join(__dirname, 'fixtures', 'bad.styl');
const goodPath = path.join(__dirname, 'fixtures', 'good.styl');
const errorPath = path.join(__dirname, 'fixtures', 'error.styl');

describe('The stylint provider for Linter', () => {
  const { lint } = require('../lib/init.js').provideLinter();

  beforeEach(() => {
    atom.workspace.destroyActivePaneItem();
    waitsForPromise(() => atom.packages.activatePackage('linter-stylint'));
  });

  it('should be in the packages list', () =>
    expect(atom.packages.isPackageLoaded('linter-stylint')).toBe(true)
  );

  it('should be an active package', () =>
    expect(atom.packages.isPackageActive('linter-stylint')).toBe(true)
  );

  it('finds nothing wrong with valid file', () =>
    waitsForPromise(() =>
      atom.workspace.open(goodPath).then(editor =>
        lint(editor).then(messages => expect(messages.length).toBe(0))
      )
    )
  );

  it('finds something wrong with invalid file', () =>
    waitsForPromise(() =>
      atom.workspace.open(badPath).then(editor =>
        lint(editor).then((messages) => {
          expect(messages.length).toEqual(2);
          expect(messages[0].type).toBe('warning');
          expect(messages[0].text).toBe('unnecessary bracket (brackets)');
          expect(messages[0].html).not.toBeDefined();
          expect(messages[0].filePath).toBe(badPath);
          expect(messages[0].range).toEqual([[1, 5], [1, 7]]);
        })
      )
    )
  );

  it('handles error-level severity', () =>
    waitsForPromise(() =>
      atom.workspace.open(errorPath).then(editor =>
        lint(editor).then((messages) => {
          expect(messages.length).toEqual(1);
          expect(messages[0].type).toBe('error');
          expect(messages[0].text).toBe('unnecessary colon found (colons)');
          expect(messages[0].html).not.toBeDefined();
          expect(messages[0].filePath).toBe(errorPath);
          expect(messages[0].range).toEqual([[2, 8], [2, 9]]);
        })
      )
    )
  );
});
