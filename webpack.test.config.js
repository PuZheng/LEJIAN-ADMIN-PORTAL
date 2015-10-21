var config = require('./webpack.config.js');

var testConfig = config;

testConfig.resolve.alias.chai = 'node_modules/chai/chai.js';

testConfig.plugins.pop();

module.exports = testConfig;
