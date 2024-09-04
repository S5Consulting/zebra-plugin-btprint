var exec = require('cordova/exec');

exports.initialize = function (delay, wildcard, printerName, cancelButtonName) {
    exec(null, null, 'ZebraPluginBtPrint', 'initialize', [delay || 0, wildcard, printerName, cancelButtonName]);
};  

exports.print = function (mac, data, statusCallback) {  
    exec(statusCallback, statusCallback, 'ZebraPluginBtPrint', 'print', [mac, data]);
};
