var riot = require('riot');
var page = require('page');
var authStore = require('stores/auth.js');
var spuTypeStore = require('stores/spu-type.js');
var bus = require('riot-bus');

require('./tags/login-app.tag');
require('./tags/spu-type-list-app.tag');

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
    next();
};

var spuTypeList = function (ctx, next) {
    bus.register(spuTypeStore);
    riot.mount('#main', 'spu-type-list-app');
    bus.trigger('spuType.list.fetch');
    next();
};

page('/auth/login', resetStores, login);
page('/spu/spu-type-list', resetStores, loginRequired, spuTypeList);
page('/', '/spu/spu-type-list');

page();
