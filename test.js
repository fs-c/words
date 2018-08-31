const path = require('path');

const { copyFolder, removeFolder } = require('./src/utils');

// copyFolder(path.resolve('public'), path.resolve('public2'));

removeFolder(path.resolve('public2'));
