var __doc__ = `
a permission control library inspired by Flask-Principal(http://pythonhosted.org/Flask-Principal/)
`;
var provides = (function () {
    var _provides = {};
    return {
        clear: function () {
            _provides = {};
        },

        append: function (need, test) {
            _provides[need] = test || '';
            return this;
        },

        contains: function (need) {
            return need in _provides;
        },

        get: function (need) {
            return _provides[need];
        }
    };
})();


var Principal = function () {
    var self =this;
    this._cbs = [];
};

Principal.prototype.onIdentityChanged = function (cb) {
    this._cbs.push(cb);
};

Principal.prototype.resetIdentity = function () {
    var args = Array.prototype.slice.apply(arguments);
    this._cbs.forEach(function (cb) {
        cb.apply(null, [provides].concat(args));
    });
};

/**
 * test if needs is permitted
 *
 * @param {string|array} needs
 * */
Principal.prototype.permit = function (needs) {

    var restArgs = Array.prototype.slice.apply(arguments).slice(1);
    var ret = $.Deferred();
    ([].concat(needs)).forEach(function (need) {
        if (!provides.contains(need)) {
            ret.reject(need);
        } else if (typeof provides.get(need) === 'function') {
            provides.get(need).apply(null, restArgs).done(function () {
                ret.resolve(need);
            }).fail(function () {
                ret.reject(need);
            });
        } else {
            ret.resolve(need);
        }
    });
    return ret;
};

module.exports = new Principal();
