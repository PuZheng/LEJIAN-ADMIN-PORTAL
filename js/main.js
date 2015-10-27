var riot = require('riot');
var page = require('page');
var authStore = require('stores/auth.js');
var spuTypeStore = require('stores/spu-type.js');
var assetStore = require('stores/asset.js');
var spuStore = require('stores/spu.js');
var bus = require('riot-bus');

require('tags/login-app.tag');
require('tags/spu-type-list-app.tag');
require('tags/nav-bar.tag');
require('tags/spu-type-app.tag');
require('tags/spu-list-app.tag');

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
    page(target);
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
};

var spuTypeList = function (ctx, next) {
    bus.register(spuTypeStore);
    riot.mount('#main', 'spu-type-list-app');
    bus.trigger('spuType.list.fetch');
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

var spuList = function (ctx, next) {
    bus.register(spuStore);
    bus.register(assetStore);
    riot.mount('#main', 'spu-list-app');
    bus.trigger('spu.list.fetch');
};

page(function (ctx, next) {
    var qs = ctx.querystring;
    ctx.query = {};

    if (qs) {
        qs.split('&').forEach(function(v) {
            var c = v.split('=');
            ctx.query[c[0]] = Array.prototype.concat.apply([], c.slice(1)).join('=');
        });
    }
    next();
});

page('/auth/login', resetStores, navBar, login);
page('/spu/spu-type-list', resetStores, loginRequired, navBar, spuTypeList);
page('/spu/spu-type/', resetStores, loginRequired, navBar, spuType);
page('/spu/spu-type/:id', resetStores, loginRequired, navBar, spuType);
page('/spu/spu-list', resetStores, loginRequired, navBar, spuList);
page('/', '/spu/spu-type-list');

page();
