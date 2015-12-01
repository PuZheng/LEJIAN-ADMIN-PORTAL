var riot = require('riot');
var request = require('request');
var bus = require('riot-bus');

var VendorStore = function () {
    riot.observable(this);
};

VendorStore.prototype.fetchList = function () {
    var d = $.Deferred();
    bus.trigger('vendor.list.fetching');
    request('/vendor/vendor-list').done(function (res) {
        bus.trigger('vendor.list.fetched', res.body);
        bus.trigger('vendor.list.fetch.done');
        d.resolve(res.body);
    }.bind(this)).fail(function (err, res) {
        bus.trigger('vendor.list.fetch.failed', err);
        bus.trigger('vendor.list.fetch.done');
        d.reject(err);
    });
    return d;
};

module.exports = new VendorStore();
