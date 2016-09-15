'use babel';

import { CompositeDisposable } from 'atom';
import path from 'path';
import * as helpers from 'atom-linter';

// Internal vars
let subscriptions;
// Settings
let executablePath;
let projectConfigFile;
let runWithStrictMode;
let onlyRunWhenConfig;

export const config = {
  executablePath: {
    type: 'string',
    default: path.join(__dirname, '..', 'node_modules', 'stylint', 'bin', 'stylint'),
    description: 'Full path to the `stylint` executable node script ' +
      'file (e.g. /usr/local/bin/stylint)',
  },
  projectConfigFile: {
    type: 'string',
    default: '.stylintrc',
    description: 'Relative path from project to config file',
  },
  runWithStrictMode: {
    default: false,
    title: 'Always run Stylint in \'strict mode\' (Config not necessary)',
    type: 'boolean',
  },
  onlyRunWhenConfig: {
    default: false,
    title: 'Run Stylint only if config is found',
    type: 'boolean',
  },
};

export function activate() {
  require('atom-package-deps').install('linter-stylint');

  subscriptions = new CompositeDisposable();

  subscriptions.add(atom.config.observe('linter-stylint.executablePath', (value) => {
    executablePath = value;
  }));
  subscriptions.add(atom.config.observe('linter-stylint.projectConfigFile', (value) => {
    projectConfigFile = value;
  }));
  subscriptions.add(atom.config.observe('linter-stylint.runWithStrictMode', (value) => {
    runWithStrictMode = value;
  }));
  subscriptions.add(atom.config.observe('linter-stylint.onlyRunWhenConfig', (value) => {
    onlyRunWhenConfig = value;
  }));
}

export function deactivate() {
  subscriptions.dispose();
}

export function provideLinter() {
  return {
    name: 'stylint',
    grammarScopes: [
      'source.stylus', 'source.styl', 'source.css.styl', 'source.css.stylus',
    ],
    scope: 'file',
    lintOnFly: true,
    lint: (textEditor) => {
      const filePath = textEditor.getPath();
      const fileText = textEditor.getText();

      if (!fileText) {
        return Promise.resolve([]);
      }

      const projectConfigPath = helpers.find(filePath, projectConfigFile);

      if (onlyRunWhenConfig && projectConfigPath === null) {
        atom.notifications.addError('Stylint config not found');
        return Promise.resolve([]);
      }

      const parameters = [filePath];

      if (onlyRunWhenConfig || (!runWithStrictMode && projectConfigPath !== null)) {
        parameters.push('-c', projectConfigPath);
      }

      let projectDir;
      // Attempt to use Atom's project folder for the CWD
      if (projectConfigPath === null) {
        projectDir = atom.project.relativizePath(filePath)[0];
      }
      // Fall back to the file directory if Atom wasn't opened as a project
      if (projectDir === null) {
        projectDir = path.dirname(filePath);
      }

      const options = {
        stdin: fileText,
        cwd: projectDir,
        ignoreExitCode: true,
      };

      return helpers.execNode(executablePath, parameters, options).then((result) => {
        let match;
        const regex = /([^\r\n]+)\n(\d+)(?::(\d+))?\s([\w\s]+) (warning|error) (.+)/g;
        const messages = [];

        match = regex.exec(result);
        while (match !== null) {
          messages.push({
            type: match[5],
            text: `${match[6]} (${match[4]})`,
            filePath: match[1],
            range: helpers.rangeFromLineNumber(textEditor, match[2] - 1, match[3] - 1),
          });
          match = regex.exec(result);
        }

        return messages;
      });
    },
  };
}
