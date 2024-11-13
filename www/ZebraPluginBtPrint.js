var exec = require('cordova/exec');

exports.initialize = function (delay, wildcard, printerName, cancelButtonName) {
    exec(null, null, 'ZebraPluginBtPrint', 'initialize', [delay || 0, wildcard, printerName, cancelButtonName]);
};  

// exports.print = function (mac, data, statusCallback) {  
//     exec(statusCallback, statusCallback, 'ZebraPluginBtPrint', 'print', [mac, data]);
// };

exports.print = function (mac, data, caseValue, statusCallback) {  
    exec(statusCallback, statusCallback, 'ZebraPluginBtPrint', 'print', [mac, data, caseValue]);
};

exports.status = function(statusCallback) {
    exec(statusCallback, statusCallback, 'ZebraPluginBtPrint', 'status', []);
};
