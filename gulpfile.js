var gulp = require('gulp');
var webpack = require('webpack');
var webpackConfig = require('./webpack.config.js');
var gutil = require('gulp-util');
var WebpackDevServer = require('webpack-dev-server');
var data = require('gulp-data');
var template = require('gulp-template');
var rename = require('gulp-rename');
var postcss = require('gulp-postcss');
var precss = require('precss');
var livereload = require('gulp-livereload');

gulp.task('template-compile', function () {
    var config = require('./convict-def.js');
    gulp.src('js/config.js.tpl').pipe(data(config.getProperties())).pipe(template()).pipe(rename(function (path) {
        path.extname = '';
    })).pipe(gulp.dest('js/'));
});

gulp.task('watch', function () {
    livereload.listen();
    gulp.watch(['js/config.js.tpl', 'convict-def.js'], ['template-compile']);
    gulp.watch('postcss/*.css', ['css']);
    gulp.watch('js/tags/*.tag.tmpl', ['render']);
});

gulp.task('webpack:build-dev', function(callback) {
    // modify some webpack config options
    var myDevConfig = Object.create(webpackConfig);
    myDevConfig.devtool = 'source-map';
    myDevConfig.debug = true;

    // create a single instance of the compiler to allow caching
    var devCompiler = webpack(myDevConfig);
	// run webpack
	devCompiler.run(function(err, stats) {
		if(err) throw new gutil.PluginError('webpack:build-dev', err);
		gutil.log('[webpack:build-dev]', stats.toString({
			colors: true
		}));
		callback();
	});
});

gulp.task('webpack:build-test', function(callback) {
    // modify some webpack config options
    var myDevConfig = Object.create(webpackConfig);
    myDevConfig.devtool = 'source-map';
    myDevConfig.debug = true;
    myDevConfig.entry = ['./test/js/test-auth.js'];
    myDevConfig.output = {
        path: __dirname + '/test/js/bundle/',
        filename: '[name].js',
    };
    myDevConfig.plugins.pop();

    // create a single instance of the compiler to allow caching
    var devCompiler = webpack(myDevConfig);
	// run webpack
	devCompiler.run(function(err, stats) {
		if(err) throw new gutil.PluginError('webpack:build-dev', err);
		gutil.log('[webpack:build-dev]', stats.toString({
			colors: true
		}));
		callback();
	});
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

gulp.task('test', function () {
    return gulp.src('test/test-auth.html')
    .pipe(require('gulp-mocha-phantomjs')());
});

gulp.task('css', function () {
    gulp.src('postcss/*.css').pipe(postcss([precss])).pipe(gulp.dest('./css')).pipe(livereload());
});


var rollup = require('gulp-rollup');
var sourcemaps = require('gulp-sourcemaps');
var commonjs = require('rollup-plugin-commonjs');
var npm = require('rollup-plugin-npm');

gulp.task('bundle', function(){
  gulp.src('js/test.js', {read: false})
    .pipe(rollup({
        // any option supported by rollup can be set here, including sourceMap

        plugins: [
            npm({
                jsnext: true,
                main: true
            }),
            commonjs({
                include: 'node_modules/*',
            })
        ],
        sourceMap: true
    }))
    .pipe(sourcemaps.write(".")) // this only works if the sourceMap option is true
    .pipe(gulp.dest('dist'));
});

var nunjucksRender = require('gulp-nunjucks-render');

gulp.task('render', function () {
    return gulp.src(['js/tags/vendor-table.tag.tmpl']).pipe(data(function () {
        return {
            'listFetchEvent': 'vendor.list.fetched',
            'tagName': 'vendor-table',
        };
    }))
        .pipe(nunjucksRender()).pipe(rename(function (path) {
            path.extname = '';
        })).pipe(gulp.dest('js/tags/')).pipe(livereload());
});
