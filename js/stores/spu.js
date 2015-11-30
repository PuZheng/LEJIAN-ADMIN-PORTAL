var riot = require('riot');
var request = require('request');
var bus = require('riot-bus');
var camelCase = require('camelcase');
var buildQS = require('build-qs');

var SPUStore = function () {
    riot.observable(this);
    this.on('spu.list.fetch', function (query) {
        this.fetchList(query);
    }).on('error', function (err) {
        console.error(err);
    });
};

SPUStore.prototype.fetchList = function (query) {
    bus.trigger('spu.list.fetching');
    request('/spu/spu-list?' + buildQS(query)).done(function (res) {
        bus.trigger('spu.list.fetched', res.body);
        bus.trigger('spu.list.fetch.done');
    }.bind(this)).fail(function (err, res) {
        bus.trigger('spu.list.fetch.failed', err);
        bus.trigger('spu.list.fetch.done');
    });
};

module.exports = new SPUStore();
