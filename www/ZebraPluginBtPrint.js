let exec = require('cordova/exec');

let App = function() {
    lexit.btprint.initialize = function (delay) {
        exec(null, null, 'ZebraPluginBtPrint', 'initialize', [delay || 0]);
    };

    lexit.btprint.print = function (mac, data, statusCallback) {
        exec(statusCallback, statusCallback, 'ZebraPluginBtPrint', 'print', [mac, data]);
    };
};

module.exports = App;




