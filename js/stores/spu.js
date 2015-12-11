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

module.exports = new SPUStore();
