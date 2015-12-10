var riot = require('riot');
var bus = require('riot-bus');

var SKUStore = function() {
    riot.observable(this);
    this.on('sku.list.fetch', function (query) {
        this.fetchList(query);
    });
};

SKUStore.prototype.fetchList = function (query) {
    var d = $.Deferred();
    bus.trigger('sku.list.fetching', query);

    setTimeout(function () {
        var data = {
            data: [],
            totalCnt: 10000,
        };
        bus.trigger('sku.list.fetched', data);
        bus.trigger('sku.list.fetch.done');
        d.resolve(data);
    }, 1000);

    return d;
};

module.exports = new SKUStore();
