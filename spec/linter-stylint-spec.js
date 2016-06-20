'use babel';

import path from 'path';

const badPath = path.join(__dirname, 'fixtures', 'bad.styl');
const goodPath = path.join(__dirname, 'fixtures', 'good.styl');

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
        lint(editor).then(messages => {
          expect(messages.length).toEqual(2);
          expect(messages[0].type).toBe('Warning');
          expect(messages[0].text).toBe('unnecessary bracket');
          expect(messages[0].html).not.toBeDefined();
          expect(messages[0].filePath).toBe(badPath);
          expect(messages[0].range).toEqual([[1, 0], [1, 7]]);
        })
      )
    )
  );
});
