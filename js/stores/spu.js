var riot = require('riot');
var request = require('request');
var bus = require('riot-bus');
var buildQS = require('build-qs');

var SPUStore = function () {
    riot.observable(this);
    this.on('spu.list.fetch', function (query) {
        this.fetchList(query);
    }).on('spu.delete', function (ids) {
        this.delete(ids);
    }).on('spu.create', function (data) {
        this.create(data);
    }).on('spu.fetch', function (id) {
        this.fetch(id);
    });
};

SPUStore.prototype.fetchList = function (query) {
    var d = $.Deferred();
    bus.trigger('spu.list.fetching', query);
    request('/spu/spu-list?' + buildQS(query)).done(function (res) {
        bus.trigger('spu.list.fetched', res.body);
        bus.trigger('spu.list.fetch.done');
        d.resolve(res.body);
    }.bind(this)).fail(function (err, res) {
        bus.trigger('spu.list.fetch.failed', err);
        bus.trigger('spu.list.fetch.done');
        d.reject(err);
    });
    return d;
};

SPUStore.prototype.delete = function (ids) {
    var d = $.Deferred();
    bus.trigger('spu.deleting');
    request.delete('/spu/spu-list?ids=' + ids.join(',')).done(function (res) {
        bus.trigger('spu.deleted', ids, res.body);
        bus.trigger('spu.delete.done');
        d.resolve(ids, res.body);
    }).fail(function (err, res) {
        bus.trigger('spu.delete.failed', ids, err);
        bus.trigger('spu.delete.done');
        d.reject(err);
    });
    return d;

};

SPUStore.prototype.create = function (data) {
    var d = $.Deferred();
    bus.trigger('spu.creating', data);
    request.post('/spu/spu', data).done(function (res) {
        bus.trigger('spu.created', res.body, data);
        bus.trigger('spu.create.done');
        d.resolve(res.body, data);
    }).fail(function (err, res) {
        bus.trigger('spu.create.failed', err, data);
        bus.trigger('spu.delete.done');
        d.reject(err, id);
    });
    return d;
};

SPUStore.prototype.fetch = function (id) {
    var d = $.Deferred();
    bus.trigger('spu.fetching', id);
    request('/spu/spu/' + id).done(function (res) {
        bus.trigger('spu.fetched', res.body);
        bus.trigger('spu.fetch.done');
        d.resolve(res.body);
    }).fail(function (err, res) {
        bus.trigger('spu.fetch.failed', err, id);
        bus.trigger('spu.fetch.done');
        d.reject(err, id);
    });
    return d;
};

module.exports = new SPUStore();
