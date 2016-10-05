'use babel';

// eslint-disable-next-line import/extensions
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
      'file (e.g. /usr/local/bin/stylint). Note that `stylint-json-reporter` ' +
      'must be installed in this node_modules folder.',
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

      const parameters = [filePath, '--reporter', 'stylint-json-reporter'];

      if (!runWithStrictMode && projectConfigPath !== null) {
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
        if (textEditor.getText() !== fileText) {
          // Text has been modified since the initial call, tell Linter not to update results
          return null;
        }

        let data;
        try {
          data = JSON.parse(result)[0];
        } catch (e) {
          const message = 'Error parsing stylint output';
          const msgOptions = {
            description: 'Something went wrong parsing the stylint output, ' +
              'please see the console for details.',
          };
          atom.notifications.addError(message, msgOptions);
          // eslint-disable-next-line no-console
          console.error('linter-stylint: Failed to parse output as JSON', result);
          return null;
        }

        return data.messages.reduce((prev, curr) =>
          prev.concat([{
            type: curr.severity,
            text: `${curr.message} (${curr.rule})`,
            filePath,
            range: helpers.rangeFromLineNumber(textEditor,
              curr.line - 1,
              curr.column !== -1 ? curr.column - 1 : undefined
            ),
          }])
        , []);
      });
    },
  };
}
