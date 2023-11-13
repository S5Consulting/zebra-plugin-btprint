import Foundation
import ExternalAccessory

@objc(ZebraPluginBtPrint)
class ZebraPluginBtPrint: CDVPlugin {
    var printerConnection: ZebraPrinterConnection?
    var printer: ZebraPrinter?
    
    // This 
    func initialize(_ command: CDVInvokedUrlCommand) {

    }


    // old print function 
    // @objc func print(_ command: CDVInvokedUrlCommand) {
    //     let cpcl = command.arguments[0] as? String ?? ""
    //     let data = cpcl.data(using: .utf8)

    //         //Connect printer
    //         do {
    //             try printerConnection.open()
    //         } catch let error {
    //             NSLog("Error connecting to printer")
    //             return
    //         }

    //     do {
    //         try printer.send(data)
    //         statusCallback?()
    //     } 

    //     printerConnection.close()
    // }


    // new print function after adapting code from capacitor to Cordova 
    @objc func print(_ command: CDVInvokedUrlCommand) {
        let cpcl = command.arguments[0] as? String ?? ""
        let data = cpcl.data(using: .utf8)

        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

        if self.isConnected() {
            do {
                printerConnection?.close()
                try printerConnection?.open()
                try printerConnection?.write(data)
                pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
            } catch let error as NSError {
                NSLog("Error printing: \(error.localizedDescription)")
                pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)
            }
        } else {
            NSLog("Printer not connected")
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Printer Not Connected")
        }

        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
    /**
     * Check if we are connectd to the printer or not
     *
     */
    private func isConnected() -> Bool{
        //printerConnection!.isConnected lies, it says it's open when it isn't
        return self.printerConnection != nil && (self.printerConnection?.isConnected() ?? false)
    }


}