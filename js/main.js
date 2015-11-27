var riot = require('riot');
var page = require('page');
var authStore = require('stores/auth.js');
var spuTypeStore = require('stores/spu-type.js');
var spuStore = require('stores/spu.js');
var assetStore = require('stores/asset.js');
var bus = require('riot-bus');
var camelCase = require('camelcase');

require('tags/login-app.tag');
require('tags/spu-type-list-app.tag');
require('tags/nav-bar.tag');
require('tags/spu-type-app.tag');

var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');
var principal = require('principal');


var workspace = {
    stores: [],
};

riot.observable(workspace);

workspace.on('login.required logout.done', function () {
    page('/auth/login');
}).on('go', function (target) {
    page.show(target);
}).on('error', function (err) {
    throw err;
});

var resetStores = function (ctx, next) {
    bus.clear();
    bus.register(workspace);
    next();
};

var loginRequired = function (ctx, next) {
    if (authStore.authenticated()) {
        ctx.user = authStore.user();
        bus.register(authStore);
        principal.resetIdentity(ctx);
        next();
    } else {
        bus.trigger('login.required', ctx);
    }
};

var login = function (ctx, next) {
    riot.mount('#main', 'login-app');
    bus.register(authStore);
    next();
};

var spuTypeList = function (ctx, next) {
    bus.register(spuTypeStore);
    workspace.app = riot.mount('#main', 'spu-type-list-app', { ctx: ctx })[0];
    workspace.appName = 'spu-type-list';
    bus.trigger('spuType.list.fetch', ctx.query);
};

var spuList = function (ctx, next) {
    bus.register(spuStore);
    workspace.app = riot.mount('#main', 'spu-list-app', { ctx: ctx })[0];
    workspace.appName = 'spu-list';
    bus.trigger('spu.list.fetch', ctx.query);
};

var navBar = function (ctx, next) {
    riot.mount('#nav-bar', 'nav-bar', {
        ctx: ctx
    });
    next();
};

var spuType = function (ctx, next) {
    bus.register(spuTypeStore);
    bus.register(assetStore);
    riot.mount('#main', 'spu-type-app', {
        itemId: ctx.params.id
    });
    ctx.params.id && bus.trigger('spuType.fetch', ctx.params.id);
};

page(function (ctx, next) {
    var qs = ctx.querystring;
    ctx.query = {};

    if (qs) {
        // there's a potential bug, see https://github.com/visionmedia/page.js/issues/216
        qs.split('&').forEach(function(v) {
            var c = v.split('=');
            ctx.query[camelCase(c[0])] = decodeURIComponent(Array.prototype.concat.apply([], c.slice(1)).join('='));
        });
    }
    next();
});

page('/auth/login', resetStores, navBar, login);
page('/spu/spu-type-list', function (ctx, next) {
    if (workspace.appName === 'spu-type-list') {
        workspace.app.opts = { ctx: ctx };
        workspace.app.processOpts();
        workspace.app.update();
        bus.trigger('spuType.list.fetch', ctx.query);
    } else {
        next();
    }
}, resetStores, loginRequired, navBar, spuTypeList);
page('/spu/spu-list', function (ctx, next) {
    if (workspace.appName === 'spu-list') {
        workspace.app.opts = { ctx: ctx };
        workspace.app.processOpts();
        workspace.app.update();
    }
}, resetStores, loginRequired, navBar, spuList);
page('/spu/spu-type/:id', resetStores, loginRequired, navBar, spuType);
page('/', '/spu/spu-type-list');

page();
