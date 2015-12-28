var riot = require('riot');
var page = require('page');
var authStore = require('stores/auth.js');
var spuTypeStore = require('stores/spu-type.js');
var spuStore = require('stores/spu.js');
var assetStore = require('stores/asset.js');
var vendorStore = require('stores/vendor.js');
var retailerStore = require('stores/retailer.js');
var skuStore = require('stores/sku.js');
var bus = require('riot-bus');
var camelCase = require('camelcase');
var config = require('config');
require('semantic-ui/semantic.js');

require('tags/login-app.tag');
require('tags/spu-type-list-app.tag');
require('tags/spu-type-app.tag');
require('tags/nav-bar.tag');
require('tags/spu-list-app.tag');
require('tags/spu-app.tag');
require('tags/vendor-list-app.tag');
require('tags/retailer-list-app.tag');
require('tags/sku-list-app.tag');
require('tags/vendor-app.tag');

var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');
var principal = require('principal');

// see https://github.com/riot/riot/issues/871
if (config.env === 'development') {
    riot.util.tmpl.errorHandler = function (err) {
        // console.error(err);
    };
}


var workspace = {
    stores: [],
};

riot.observable(workspace);

workspace.on('login.required logout.done', function () {
    page('/auth/login');
}).on('go', function (target) {
    page.show(target);
}).on('error', function (err) {
    console.error(err);
});

// VIEWS
//
var setTitle = function (title) {
    return function (ctx, next) {
        document.title = title;
        next();
    };
};

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
    ctx.query.page = ctx.query.page || 1;
    ctx.query.perPage = ctx.query.perPage || 12;
    spuStore.fetchList(ctx.query);
    vendorStore.fetchList();
    spuTypeStore.fetchList({});
};

var vendorList = function (ctx, next) {
    bus.register(vendorStore);
    workspace.app = riot.mount('#main', 'vendor-list-app', { ctx: ctx })[0];
    workspace.appName = 'vendor-list';
    vendorStore.fetchList(ctx.query);
};

var retailerList = function (ctx, next) {
    bus.register(retailerStore);
    workspace.app = riot.mount('#main', 'retailer-list-app', { ctx: ctx })[0];
    workspace.appName = 'retailer-list';
    retailerStore.fetchList(ctx.query);
};

var skuList = function (ctx, next) {
    bus.register(skuStore);
    _.assign(ctx.query, {
        page: 1,
        perPage: 16,
    });
    workspace.app = riot.mount('#main', 'sku-list-app', {
        ctx: ctx
    })[0];
    workspace.appName = 'sku-list';
    skuStore.fetchList(ctx.query).done(function () {
        spuStore.fetchList();
    });
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
    workspace.app = riot.mount('#main', 'spu-type-app', {
        ctx: ctx,
    })[0];
    workspace.appName = 'spu-type';
    ctx.params.id && bus.trigger('spuType.fetch', ctx.params.id);
};

var spu = function (ctx, next) {
    bus.register(spuStore);
    bus.register(spuTypeStore);
    bus.register(vendorStore);
    bus.register(assetStore);
    workspace.app = riot.mount('#main', 'spu-app', { ctx: ctx })[0];
    workspace.appName = 'spu';
    ctx.params.id && bus.trigger('spu.fetch', ctx.params.id);
    bus.trigger('spuType.list.fetch');
    bus.trigger('vendor.list.fetch');
};

var vendor = function (ctx, next) {
    bus.register(vendorStore);
    workspace.app = riot.mount('#main', 'vendor-app', {ctx: ctx})[0];
    workspace.appName = 'vendor';
    ctx.params.id && bus.trigger('vendor.fetch', ctx.params.id);
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
page('/spu-type-list', function (ctx, next) {
    if (workspace.appName === 'spu-type-list') {
        // only update
        workspace.app.opts = { ctx: ctx };
        workspace.app.update();
        bus.trigger('spuType.list.fetch', ctx.query);
    } else {
        next();
    }
}, resetStores, loginRequired, navBar, setTitle('乐鉴-SPU分类列表'), spuTypeList);
page('/spu-list', function (ctx, next) {
    if (workspace.appName === 'spu-list') {
        // only update
        workspace.app.opts = { ctx: ctx };
        workspace.app.update();
        bus.trigger('spu.list.fetch', ctx.query);
    } else {
        next();
    }
}, resetStores, loginRequired, navBar, setTitle('乐鉴-SPU列表'), spuList);
page('/vendor-list', function (ctx, next) {
    if (workspace.appName === 'vendor-list') {
        workspace.app.opts = { ctx: ctx };
        workspace.app.update();
        bus.trigger('vendor.list.fetch', ctx.query);
    } else {
        next();
    }
}, resetStores, loginRequired, navBar, setTitle('乐鉴-厂商列表'), vendorList);
page('/retailer-list', function (ctx, next) {
    if (workspace.appName === 'retailer-list') {
        workspace.app.opts = { ctx: ctx };
        workspace.app.update();
        bus.trigger('retailer.list.fetch', ctx.query);
    } else {
        next();
    }
}, resetStores, loginRequired, navBar, setTitle('乐鉴-零售商列表'), retailerList);
page('/sku-list', function (ctx, next) {
    if (workspace.appName === 'sku-list') {
        workspace.app.opts = { ctx: ctx };
        workspace.app.update();
        bus.trigger('sku.list.fetch', ctx.query);
    } else {
        next();
    }
}, resetStores, loginRequired, navBar, setTitle('乐鉴-SKU列表'), skuList);
page('/spu-type/:id?', function (ctx, next) {
    if (workspace.appName === 'spu-type') {
        workspace.app.opts = { ctx: ctx };
        workspace.app.update();
    } else {
        next();
    }
}, resetStores, loginRequired, navBar, spuType);
page('/spu/:id?', function (ctx, next) {
    if (workspace.appName === 'spu') {
        workspace.app.opts = { ctx: ctx };
        workspace.app.update();
    } else {
        next();
    }
}, resetStores, loginRequired, navBar, spu);
page('/vendor/:id?', function (ctx, next) {
    if (workspace.appName === 'spu') {
        workspace.app.opts = { ctx: ctx };
        workspace.app.update();
    } else {
        next();
    }
}, resetStores, loginRequired, navBar, vendor);

page('/', '/spu-list');

page();
