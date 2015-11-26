var riot = require('riot');
var request = require('request');
var bus = require('riot-bus');
var camelCase = require('camelcase');

var SPUTypeStore = function () {
    riot.observable(this);
    this.on('spuType.list.fetch', function (query) {
        this.fetchList(query);
    }).on('spuType.update', function (item, patch) {
        this.update(item, patch);
    }).on('spuType.fetch', function (id) {
        this.fetch(id);
    }).on('spuType.delete', function (ids) {
        this.delete(ids);
    }).on('spuType.create', function (data) {
        this.create(data);
    });
};

SPUTypeStore.prototype.fetchList = function (query) {
    bus.trigger('spuType.list.fetching');
    var setupItems = function (query, items) {
        if (query.sortBy) {
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
    if (this.items) {
        bus.trigger('spuType.list.fetched', {
            data: setupItems(query, this.items),
        });
        bus.trigger('spuType.list.fetch.done');
    } else {
        request('/spu/spu-type-list').done(function (res) {
            this.items = res.body.data;
            bus.trigger('spuType.list.fetched', {
                data: setupItems(query, this.items)
            });
            bus.trigger('spuType.list.fetch.done');
        }.bind(this)).fail(function (err, res) {
            bus.trigger('spuType.list.fetch.failed', err);
            bus.trigger('spuType.list.fetch.done');
        });
    }
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

SPUTypeStore.prototype.delete = function (ids) {
    bus.trigger('spuType.deleting');
    request.delete('/spu/spu-type-list/?ids=' + ids.join(',')).done(function (res) {
        this.items = this.items.filter(function (item) {
            return ids.indexOf(item.id) === -1;
        });
        bus.trigger('spuType.deleted', ids, res.body);
        bus.trigger('spuType.delete.done');
    }.bind(this)).fail(function (err, res) {
        bus.trigger('spuType.delete.failed', ids, err);
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
