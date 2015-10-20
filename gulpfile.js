var gulp = require('gulp');
var webpack = require('webpack');
var webpackConfig = require('./webpack.config.js');
var gutil = require('gulp-util');
var WebpackDevServer = require('webpack-dev-server');
var data = require('gulp-data');
var template = require('gulp-template');
var rename = require('gulp-rename');

gulp.task('template-compile', function () {
    var config = require('./convict-def.js');
    gulp.src('js/config.js.tmpl').pipe(data(config.getProperties())).pipe(template()).pipe(rename(function (path) {
        path.extname = '';
    })).pipe(gulp.dest('js/'));
});

gulp.task('watch', function () {
    gulp.watch(['js/config.js.tpl', 'convict-def.js'], ['template-compile']);
});

gulp.task('webpack-dev-server', function(callback) {
    // Start a webpack-dev-server
    var config = Object.create(require('./webpack.hot.config.js'));

    for (var k in config.entry) {
        config.entry[k].unshift('webpack-dev-server/client?http://127.0.0.1:8080');
    }

    var compiler = webpack(config);

    new WebpackDevServer(compiler, {
        // server and middleware options
        publicPath: config.output.publicPath,
        historyApiFallback: true,
    }).listen(8080, 'localhost', function(err) {
        if(err) throw new gutil.PluginError('webpack-dev-server', err);
        // Server listening
        gutil.log('[webpack-dev-server]', 'http://localhost:8080/webpack-dev-server/index.html');

        // keep the server alive or continue?
        // callback();
    });
});

gulp.task('default', ['template-compile', 'watch', 'webpack-dev-server']);
