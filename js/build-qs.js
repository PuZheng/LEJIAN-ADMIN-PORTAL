var decamelize = require('decamelize');
module.exports = function (query) {
    return _.pairs(query).filter(function (p) {
        return !!p[1];
    }).map(function (p) {
        return decamelize(p[0]) + '=' + p[1];
    }).join('&');
};
