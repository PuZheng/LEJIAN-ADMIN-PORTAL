var riot = require('riot');
var request = require('request');
var bus = require('riot-bus');

var SPUStore = function () {
    riot.observable(this);
    this.on('spu.list.fetch', function () {
        this.fetchList();
    });
};


SPUStore.prototype.fetchList = function () {
    bus.trigger('spu.list.fetching');
    request('/spu/spu-list').done(function (res) {
        bus.trigger('spu.list.fetched', res.body);
        bus.trigger('spu.list.fetche.end');
    }).fail(function (err, res) {
        bus.trigger('spu.list.fetch.failed');
        bus.trigger('spu.list.fetche.end');
    });
};

module.exports = new SPUStore();
