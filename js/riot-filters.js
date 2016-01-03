var _ = require('lodash');

var filters = {
    attr: function (o, attrName) {
        if (_.isArray(o)) {
            return o.map(function (i) {
                return i[attrName];
            });
        }
        throw new Error('argument should be an array');
    }
};

exports.Mixin = {
    init: function () {
        this._filters_ = filters;
    }
};
