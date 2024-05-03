cordova.define("s5-zebra-plugin-btprint.ZebraPluginBtPrint", function(require, exports, module) {
    let exec = require('cordova/exec');
    
    let App = function() {
        this.initialize = function (delay, wildcard, printerName, cancelButtonName) {
            exec(null, null, "ZebraPluginBtPrint", "initialize", [
              delay || 0,
              wildcard,
              printerName,
              cancelButtonName,
            ]);
          };
        
        this.print = function (mac, data, statusCallback) {
            exec(statusCallback, statusCallback, 'ZebraPluginBtPrint', 'print', [mac, data]);
        };
    };
    
    module.exports = App;
    
    
    
    
    
    });
    