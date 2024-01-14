import Foundation
import ExternalAccessory

@objc(ZebraPluginBtPrint)
class ZebraPluginBtPrint: CDVPlugin {
    var printerConnection: MfiBtPrinterConnection?
    var printer: ZebraPrinter?
    var manager: EAAccessoryManager!
    private var serialNumber: String?
    var isConnected: Bool = false

    
    @objc func findConnectedPrinter(completion: (Bool) -> Void) {
        let manager = EAAccessoryManager.shared()
        let connectedDevices = manager.connectedAccessories
        for device in connectedDevices {
            if device.protocolStrings.contains("com.zebra.rawport") {
                serialNumber = device.serialNumber
                NSLog("Zebra device found with serial number -> ")
                NSLog(serialNumber ?? "")
                connectToPrinter(completion: { completed in
                    completion(completed)
                })
            }
        }
    }
    
    @objc private func connectToPrinter( completion: (Bool) -> Void) {
        printerConnection = MfiBtPrinterConnection(serialNumber: serialNumber)
        printerConnection?.open()
        completion(true)
    }
    
    @objc func initialize(_ command: CDVInvokedUrlCommand) {
        findConnectedPrinter { [weak self] bool in
             if let strongSelf = self {
                 strongSelf.isConnected = bool
             }
         }
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
        
        var printError: NSError!
        
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
        
        if self.isConnected {
            do {
                printerConnection?.close()
                try printerConnection?.open()
                try printerConnection?.write(data, error: &printError)
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
    
    private func isConnected() -> Bool{
        //printerConnection!.isConnected lies, it says it's open when it isn't
        return self.printerConnection != nil && (self.printerConnection?.isConnected() ?? false)
    }
     */
    
}
