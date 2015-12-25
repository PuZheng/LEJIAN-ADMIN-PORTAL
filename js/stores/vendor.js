var riot = require('riot');
var request = require('request');
var bus = require('riot-bus');
var camelCase = require('camelcase');

var VendorStore = function () {
    riot.observable(this);
    this.on('vendor.list.fetch', function (query) {
        this.fetchList(query);
    });
};

VendorStore.prototype.fetchList = function (query) {
    query = query || {};
    var d = $.Deferred();
    bus.trigger('vendor.list.fetching');
    var setupItems = function (items) {
        if (query.sortBy)  {
            var sortBy = query.sortBy.split('.');
            var field = camelCase(sortBy[0]);
            var order = sortBy[1];
            items = _(items).sortBy(function (item) {
                return item[field] * {
                    'asc': 1,
                    'desc': -1,
                }[order];
            }).value();
        }
        if (query.onlyEnabled === '1') {
            items = items.filter(function (item) {
                return item.enabled;
            });
        }
        if (query.kw) {
            items = items.filter(function (item) {
                return ~item.name.toLowerCase().indexOf(query.kw.toLowerCase());
            });
        }
        return items;
    };
    var done = function (data) {
        bus.trigger('vendor.list.fetched', data);
        bus.trigger('vendor.list.fetch.done');
        d.resolve(data);
    };
    var fail = function (err, res) {
        bus.trigger('vendor.list.fetch.failed', err);
        bus.trigger('vendor.list.fetch.done');
        d.reject(err);
    };
    if (this.items) {
        done.apply(this, [{
            data: setupItems(this.items),
        }]);
    } else {
        request('/vendor/list').done(function (res) {
            this.items = res.body.data;
            done.apply(this, [{
                data: setupItems(this.items)
            }]);
        }.bind(this)).fail(fail);
    }
    return d;
};

module.exports = new VendorStore();
