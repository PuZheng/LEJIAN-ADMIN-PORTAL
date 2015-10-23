var riot = require('riot');
var config = require('config');
var bus = require('riot-bus');
var agent = require('superagent');
var noCache = require('superagent-no-cache');

var Auth = function () {
    riot.observable(this);
    this.on('login', function (emailOrName, password) {
        this.login(emailOrName, password);
    });
    this.on('logout', function () {
        this.logout();
    });
    this.on('user.updated', function (user) {
        this._user.name = user.name;
        sessionStorage.setItem('user', JSON.stringify(this._user));
    });
};

Auth.prototype.login = function (emailOrName, password) {
    var self = this;
    bus.trigger('login.start');
    agent.post(config.backend + '/auth/login')
    .use(noCache)
    .type('json')
    .accept('json')
    .send({
        emailOrName: emailOrName,
        password: password
    })
    .end(function (err, res) {
        if (err) {
            bus.trigger('login.failed', res && res.body.reason);
        } else {
            self._user = res.body;
            sessionStorage.setItem('user', res.text);
            bus.trigger('login.done', res.body);
        }
    });
};

Auth.prototype.logout = function (emailOrName, password) {
    self._user = null;
    sessionStorage.removeItem('user');
    bus.trigger('logout.done');
};

Auth.prototype.authenticated = function () {
    this._user = this._user || JSON.parse(sessionStorage.getItem('user'));
    return !!this._user;
};

Auth.prototype.user = function () {
    return this._user;
};

module.exports = new Auth();
