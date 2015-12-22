var chai = require('chai');
chai.use(function (chai, utils) {
    require('chai-jquery')(chai, utils, $);
});
var expect = chai.expect;
var riot = require('riot');
var tagInjector = require('inject?riot-bus!tags/login-app.tag');
var fakeBus = {
    Mixin: {
        init: function () {}
    },
    trigger: function () {
        var args;
        var ret = function () {
            args = Array.prototype.slice.apply(arguments);
        };

        ret.calledWith = function () {
            var args_ = arguments && Array.prototype.slice.apply(arguments);
            expect(args).to.not.be.a('null');
            expect(args.length).to.equal(args.length);
            for (var i = 0; i < args.length; ++i) {
                expect(args[i]).to.equal(args_[i]);
            }
        };
        return ret;
    }(),
    register: function () {

    },
    unregister: function () {

    }
};


tagInjector({
    'riot-bus': fakeBus,
});

var tag;

describe('login-app', function () {
    before(function () {
        $('<div id="main" style="display: none"></div>').appendTo($('body'));
        tag = riot.mount('#main', 'login-app')[0];
    });
    it('submit the form, "login" will be sent to bus', function () {
        $(tag.email).val('admin@lejian.com');
        $(tag.password).val('admin');
        var $form = $(tag.root).find('form');
        $form.find(':submit').click();
        fakeBus.trigger.calledWith('login', 'admin@lejian.com', 'admin');
    });
    it('trigger tag with "login.done", bus will receive "go"', function () {
        var user = {};
        tag.trigger('login.done', user);
        fakeBus.trigger.calledWith('go', '/');
    });
    it('trigger tag with "login.failed", error message will be displayed', function () {
        var reason = '错误的邮箱或者密码';
        tag.trigger('login.failed', reason);
        expect($(tag.root).find('.error.message')).to.have.text(reason);
    });
});
