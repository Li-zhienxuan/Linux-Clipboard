// Bootstrap file for Electron main process
// This file loads the actual ESM main process

const { path } = require('path');
const { url } = require('url');

// Import the ESM main process
const mainPath = pathToFileURL(path.join(__dirname, 'index.js')).href;

import(mainPath).catch((error) => {
  console.error('Failed to load main process:', error);
  process.exit(1);
});
