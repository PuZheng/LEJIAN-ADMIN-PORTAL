var riot = require('riot');
var request = require('request');
var bus = require('riot-bus');
var camelCase = require('camelcase');

var VendorStore = function () {
    riot.observable(this);
    this.on('vendor.list.fetch', function (query) {
        this.fetchList(query);
    }).on('vendor.create', function (data) {
        this.create(data);
    }).on('vendor.fetch', function (id) {
        this.fetch(id);
    }).on('vendor.update', function (orig, patch) {
        this.update(orig, patch);
    });
};

VendorStore.prototype.fetchList = function (query) {
    query = query || {};
    var d = $.Deferred();
    bus.trigger('vendor.list.fetching', query);
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

VendorStore.prototype.create = function (data) {
    var d = $.Deferred();
    bus.trigger('vendor.creating', data);
    request.post('/vendor/object', data).done(function (res) {
        bus.trigger('vendor.created', res.body);
        bus.trigger('vendor.create.done');
        d.resolve(res.body);
    }).fail(function (err, res) {
        bus.trigger('vendor.create.failed', data, err);
        bus.trigger('vendor.create.done');
        d.reject(err);
    });
    return d;
};

VendorStore.prototype.fetch = function (id) {
    var d = $.Deferred();
    bus.trigger('vendor.fetching', id);
    request('/vendor/object/' + id).done(function (res) {
        bus.trigger('vendor.fetched', res.body);
        bus.trigger('vendor.fetch.done');
    }).fail(function (err, res) {
        bus.trigger('vendor.fetch.failed', err, id);
        bus.trigger('vendor.fetch.done');
    });
    return d;
};

VendorStore.prototype.update = function (orig, patch) {
    var d = $.Deferred();
    bus.trigger('vendor.updating', orig, patch);
    request.put('/vendor/object/' + orig.id, patch).done(function (res) {
        bus.trigger('vendor.updated', res.body, orig, patch);
        bus.trigger('vendor.update.done');
        this.items && this.items.forEach(function (item) {
            if (item.id === res.body.id) {
                _.assign(item, res.body);
            }
        });
    }).fail(function (err, res) {
        bus.trigger('vendor.update.failed', err, orig, patch);
        bus.trigger('vendor.update.done');
    });
    return d;
};

module.exports = new VendorStore();
