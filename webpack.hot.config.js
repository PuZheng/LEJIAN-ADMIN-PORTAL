var config = require('./webpack.config.js');
var webpack = require('webpack');

for (var k in config.entry) {
    config.entry[k].unshift('webpack/hot/dev-server');
}

config.output.publicPath = 'http://127.0.0.1:8080/js/bundle';
config.devtool = "eval";
config.debug = true;
config.plugins = config.plugins || [];
config.devServer = {
    contentBase: "./",
    historyApiFallback: true,
};

config.plugins.push(new webpack.HotModuleReplacementPlugin());
module.exports = config;
