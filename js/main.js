var riot = require('riot');
var page = require('page');
var authStore = require('stores/auth.js');
var bus = require('riot-bus');

require('tags/login-app.tag');
require('tags/spu-type-list-app.tag');

var swal = require('sweetalert/sweetalert.min.js');
require('sweetalert/sweetalert.css');
var principal = require('principal');

require('semantic-ui/semantic.min.css');
require('semantic-ui/semantic.min.js');

var workspace = {
    stores: [],
};

riot.observable(workspace);
bus.register(workspace);

workspace.on('login.required logout.done', function () {
    page('/auth/login');
});

var clear = function (ctx, next) {
    bus.clear();
    next();
};

var loginRequired = function (ctx, next) {
    if (authStore.authenticated()) {
        ctx.user = authStore.currentUser();
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
    riot.mount('#main', 'spu-type-list-app');
    next();
};

page('/auth/login', clear, login);
page('/spu/spu-type-list', clear, loginRequired, spuTypeList);
page('/', '/spu/spu-type-list');

page();
