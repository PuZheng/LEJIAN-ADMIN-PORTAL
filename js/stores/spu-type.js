var riot = require('riot');
var request = require('request');
var bus = require('riot-bus');

var SPUTypeStore = function () {
    riot.observable(this);
    this.on('spuType.list.fetch', function () {
        this.fetchList();
    }).on('spuType.update', function (item, patch) {
        this.update(item, patch);
    }).on('spuType.fetch', function (id) {
        this.fetch(id);
    }).on('spuType.delete', function (id) {
        this.delete(id);
    }).on('spuType.create', function (data) {
        this.create(data);
    });
};

SPUTypeStore.prototype.fetchList = function () {
    bus.trigger('spuType.list.fetching');
    request('/spu/spu-type-list').done(function (res) {
        bus.trigger('spuType.list.fetched', res.body);
        bus.trigger('spuType.list.fetch.done');
    }).fail(function (err, res) {
        bus.trigger('spuType.list.fetch.failed', err);
        bus.trigger('spuType.list.fetch.done');
    });
};

SPUTypeStore.prototype.update = function (item, patch) {
    bus.trigger('spuType.updating');
    request.put('/spu/spu-type/' + item.id, patch).done(function (res) {
        bus.trigger('spuType.updated', res.body, patch);
        bus.trigger('spuType.update.done');
    }).fail(function (err, res) {
        bus.trigger('spuType.update.failed', item, patch, err);
        bus.trigger('spuType.update.done');
    });
};

SPUTypeStore.prototype.fetch = function (id) {
    bus.trigger('spuType.fetching');
    request('/spu/spu-type/' + id).done(function (res) {
        bus.trigger('spuType.fetched', res.body);
        bus.trigger('spuType.fetch.done');
    }).fail(function (err, res) {
        bus.trigger('spuType.fetch.failed', id, err);
        bus.trigger('spuType.fetch.done');
    });
};

SPUTypeStore.prototype.delete = function (id) {
    bus.trigger('spuType.deleting');
    request.delete('/spu/spu-type/' + id).done(function (res) {
        bus.trigger('spuType.deleted', id, res.body);
        bus.trigger('spuType.delete.done');
    }).fail(function (err, res) {
        bus.trigger('spuType.delete.failed', id, err);
        bus.trigger('spuType.delete.done');
    });
};

SPUTypeStore.prototype.create = function (data) {
    bus.trigger('spuType.creating');
    request.post('/spu/spu-type/', data).done(function (res) {
        bus.trigger('spuType.created', res.body);
        bus.trigger('spuType.create.done');
    }).fail(function (err, res) {
        bus.trigger('spuType.create.failed', data, err);
        bus.trigger('spuType.create.done');
    });
};

module.exports = new SPUTypeStore();
