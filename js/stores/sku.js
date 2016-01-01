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
    }).on('sku.create', function (data) {
        this.create(data);
    }).on('sku.fetch', function (id) {
        this.fetch(id);
    }).on('sku.update', function (item, patch) {
        this.update(item, patch);
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

SKUStore.prototype.create = function (data) {
    var d = $.Deferred();
    bus.trigger('sku.creating', data);
    if (_.isArray(data)) {

    }
    request.post.apply(request, _.isArray(data)?  ['sku/list', { data: data }]: ['/sku/object', data]).done(function (res) {
        bus.trigger('sku.created', res.body);
        bus.trigger('sku.create.done');
        d.resolve(res.body);
    }).fail(function (err, res) {
        bus.trigger('sku.create.failed', err);
        bus.trigger('sku.create.done');
        d.reject(err);
    });
    return d;
};

SKUStore.prototype.fetch = function (id) {
    var d = $.Deferred();
    bus.trigger('sku.fetching', id);
    request('/sku/object/' + id).done(function (res) {
        bus.trigger('sku.fetched', res.body);
        bus.trigger('sku.fetch.done');
        d.resolve(res.body);
    }).fail(function (err, res) {
        bus.trigger('sku.fetch.failed', err);
        bus.trigger('sku.fetch.done');
        d.reject(err);
    });
    return d;
};

SKUStore.prototype.update = function (item, patch)  {
    var d = $.Deferred();
    bus.trigger('sku.updating', item, patch);
    request.put('/sku/object/' + item.id, patch).done(function (res) {
        bus.trigger('sku.updated', res.body, item, patch);
        d.resolve(item, patch);
    }).fail(function (err, res) {
        bus.trigger('sku.update.failed', err, item, patch);
        d.reject(err, item, patch);
    }).always(function () {
        bus.trigger('sku.update.done');
    });
    return d;
};

module.exports = new SKUStore();
