let exec = require('cordova/exec');

let App = function() {
    this.initialize = function (delay) {
        exec(null, null, 'ZebraPluginBtPrint', 'initialize', [delay || 0]);
    };

    this.print = function (mac, data, statusCallback) {
        exec(statusCallback, statusCallback, 'ZebraPluginBtPrint', 'print', [mac, data]);
    };
};

module.exports = App;




