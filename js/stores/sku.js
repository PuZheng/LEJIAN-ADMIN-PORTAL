var riot = require('riot');
var bus = require('riot-bus');
var buildQS = require('build-qs');
var request = require('request');

var SKUStore = function() {
    riot.observable(this);
    this.on('sku.list.fetch', function (query) {
        this.fetchList(query);
    }).on('sku.delete', function (ids) {
        this.delete(ids);
    });
};

SKUStore.prototype.fetchList = function (query) {
    var d = $.Deferred();
    bus.trigger('sku.list.fetching', query);

    request('/sku/list?' + buildQS(query)).done(function (res) {
        bus.trigger('sku.list.fetched', res.body);
        bus.trigger('sku.list.fetch.done');
        d.resolve(res.body);
    }).fail(function (err, res) {

    });
    return d;
};

SKUStore.prototype.delete = function (ids) {
    var d = $.Deferred();
    bus.trigger('sku.deleting', ids);
    request.delete('/sku/list?ids=' + ids.join(',')).done(function (res) {
        bus.trigger('sku.deleted', ids, res.body);
        bus.trigger('sku.delete.done');
        d.resolve(ids, res.body);
    }).fail(function (err, res) {
        bus.trigger('sku.delete.failed', ids, err);
        bus.trigger('sku.delete.done');
        d.reject(err);
    });
    return d;
};

module.exports = new SKUStore();
