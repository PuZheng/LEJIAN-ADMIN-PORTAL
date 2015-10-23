var riot = require('riot');
var request = require('request');
var bus = require('riot-bus');

var SPUTypeStore = function () {
    riot.observable(this);
    this.on('spuType.list.fetch', function () {
        this.fetchList();
    }).on('spuType.update', function (id, patch) {
        this.update(id, patch);
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

SPUTypeStore.prototype.update = function (id, patch) {
    bus.trigger('spuType.updating');
    request.put('/spu/spu-type/' + id, patch).done(function (res) {
        bus.trigger('spuType.updated', res.body);
        bus.trigger('spuType.update.done');
    }).fail(function (err, res) {
        bus.trigger('spuType.update.failed', err);
        bus.trigger('spuType.update.done');
    });
};


module.exports = new SPUTypeStore();
