var webpack = require('webpack');
var path = require('path');
var CommonsChunkPlugin = require("webpack/lib/optimize/CommonsChunkPlugin");

var resolvePath = function(componentPath) {
    return path.join(__dirname + '/' + componentPath);
};

module.exports = {
    entry: {
        'main': ['./js/main.js'],
    },
    output: {
        path: __dirname + '/js/bundle/',
        filename: "[name].js",
    },
    resolve: {
        alias: {
            'jquery$': resolvePath('node_modules/jquery/dist/jquery.min.js'),
            'lodash$': resolvePath('node_modules/lodash/'),
            'moment': resolvePath('node_modules/moment/moment.js'),
            'sweetalert': resolvePath('node_modules/sweetalert/dist/'),
            'toastr': resolvePath('node_modules/toastr/build/'),
            'page': resolvePath('node_modules/page/'),
            'semantic-ui': resolvePath('vendors/semantic/dist'),
            'chai-jquery$': resolvePath('node_modules/chai-jquery/chai-jquery.js'),
            'url-join$': resolvePath('node_modules/url-join/lib/url-join.js'),
            'magnific-popup': resolvePath('node_modules/magnific-popup/dist/'),

            'config$': resolvePath('./js/config.js'),
            'stores': resolvePath('./js/stores'),
            'riot-bus$': resolvePath('./js/riot-bus.js'),
            'tags': resolvePath('./js/tags/'),
            'principal$': resolvePath('./js/principal.js'),
            'request$': resolvePath('./js/request.js'),
        },
        root: '.',
    },
    plugins: [
        new webpack.ProvidePlugin({
           $: "jquery",
           _: "lodash",
           jQuery: "jquery",
           'window.jQuery': 'jquery',
        }),
        new CommonsChunkPlugin("commons.chunk.js"),
    ],
    module: {
        preLoaders: [
            { test: /\.tag$/, exclude: /node_modules/, loader: 'riotjs-loader', query: { type: 'none' } }
        ],
        loaders: [
            { test: /\.css$/, loader: "style!css" },
            { test: /\.json/, loader: "json-loader" },
            { test: /\.(png|gif|jpg)$/, loader: "url-loader?limit=100000" },
            { test: /\.(ttf|eot|woff|woff2|svg)$/, loader: "url-loader?limit=100000" },
        ]
    },
};
