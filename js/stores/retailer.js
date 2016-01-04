var riot = require('riot');
var bus = require('riot-bus');
var request = require('request');
var buildQS = require('build-qs');

var RetailerStore = function () {
    riot.observable(this);
    this.on('retailer.list.fetch', function (query) {
        this.fetchList(query);
    }).on('retailer.fetch', function (id) {
        this.fetch(id);
    });
    return this;
};

RetailerStore.prototype.fetchList = function (query) {
    var d = $.Deferred();
    query = query || {};

    bus.trigger('retailer.list.fetching', query);

    request('/retailer/list?' + buildQS(query)).done(function (res) {
        bus.trigger('retailer.list.fetched', res.body);
        d.resolve(res.body);
    }).fail(function (err, res) {
        bus.trigger('retailer.list.fetch.failed', err);
        d.reject(err);
    }).always(function () {
        bus.trigger('retailer.list.fetch.done');
    });

    return d;
};

RetailerStore.prototype.fetch = function (id) {
    var d = $.Deferred();
    bus.trigger('retailer.fetching', id);

    request('/retailer/object/' + id).done(function (res) {
        bus.trigger('retailer.fetched', res.body);
        d.resolve(res.body);
    }).fail(function (err, res) {
        bus.trigger('retailer.fetch.failed', err);
        d.reject(err);
    }).always(function () {
        bus.trigger('retailer.fetch.done');
    });
    return d;
};


module.exports = new RetailerStore();
