function RiotBus() {

    this._observables = [];

}

RiotBus.prototype.register = function (observable) {
    console.log(observable + ' is registered');
    this._observables.push(observable);
};

RiotBus.prototype.unregister = function (observable) {
    console.log(observable + ' is unregistered');
    this._observables = this._observables.filter(function (o) {
        return o != observable;
    });
};

RiotBus.prototype.clear = function () {
    this._observables = [];
};

RiotBus.prototype.trigger = function (event) {

    var args = Array.prototype.slice.apply(arguments);
    console.log('trigger', args);
    this._observables.forEach(function (o) {
        o.trigger.apply(o, args);
    });
};

RiotBus.prototype.Mixin = {
    init: function () {
        var self = this;
        this.on('mount', function () {
            bus.register(self);
        }).on('unmount', function () {
            bus.unregister(self);
        });
    }
};

var bus = new RiotBus();
module.exports = bus;
