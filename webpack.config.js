var webpack = require('webpack');
var path = require('path');
var CommonsChunkPlugin = require("webpack/lib/optimize/CommonsChunkPlugin");

var resolvePath = function(componentPath) {
    return path.join(__dirname + '/' + componentPath);
};

module.exports = {
    entry: {
    },
    output: {
        path: __dirname + '/js/bundle/',
        filename: "[name].js",
    },
    resolve: {
        alias: {
        },
        root: '.',
    },
    plugins: [
        new webpack.ProvidePlugin({
        }),
        new CommonsChunkPlugin("commons.chunk.js"),
    ],
    module: {
        preLoaders: [
        ],
        loaders: [
            { test: /\.css$/, loader: "style!css" },
            { test: /\.json/, loader: "json-loader" },
            { test: /\.(png|gif|jpg)$/, loader: "url-loader?limit=100000" },
            { test: /\.(ttf|eot|woff|woff2|svg)$/, loader: "url-loader?limit=100000" },
        ]
    },
};
