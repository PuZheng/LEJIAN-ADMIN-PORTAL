var agent = require('superagent');
var noCache = require('superagent-no-cache');
var auth = require('./stores/auth.js');
var config = require('config');
var urljoin = require('url-join');

function request() {
    var args = Array.prototype.slice.call(arguments);
    return request.get.apply(null, args);
}

['put', 'post', 'get', 'delete'].forEach(function (method) {
    request[method] = function (url, data) {
        var ret = $.Deferred();
        method === 'delete' && (method = 'del');
        var a = agent[method](urljoin(config.backend, url)).use(noCache);
        !!data && (a = a.send(data));
        a.set('Authorization', 'Bearer ' + auth.user().token)
        .type('json').accept('json').end(function (err, res) {
            if (err) {
                console.error(err);
                ret.reject(err, res);
            } else {
                ret.resolve(res);
            }
        });
        return ret;
    };
});


module.exports = request;
