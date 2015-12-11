var riot = require('riot');
var bus = require('riot-bus');
var buildQS = require('build-qs');
var request = require('request');

var SKUStore = function() {
    riot.observable(this);
    this.on('sku.list.fetch', function (query) {
        this.fetchList(query);
    });
};

SKUStore.prototype.fetchList = function (query) {
    var d = $.Deferred();
    query = _.assign({
        page: 1,
        perPage: 16,
    }, query || {});
    bus.trigger('sku.list.fetching', query);

    request('/sku/list.json?' + buildQS(query)).done(function (res) {
        bus.trigger('sku.list.fetched', res.body);
        bus.trigger('sku.list.fetche.done');
        d.resolve(res.body);
    }).fail(function (err, res) {

    });
    return d;
};

module.exports = new SKUStore();
