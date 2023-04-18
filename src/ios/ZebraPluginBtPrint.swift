import Foundation
import ExternalAccessory

@objc(ZebraPluginBtPrint)
class ZebraPluginBtPrint: CDVPlugin {
    var printerConnection: ZebraPrinterConnection?
    var printer: ZebraPrinter?
    
    // This 
    func initialize(_ command: CDVInvokedUrlCommand) {

    }

 @objc func print(_ command: CDVInvokedUrlCommand) {
    let cpcl = command.arguments[0] as? String ?? ""
    let data = cpcl.data(using: .utf8)

        //Connect printer
        do {
            try printerConnection.open()
        } catch let error {
            NSLog("Error connecting to printer")
            return
        }

    do {
        try printer.send(data)
        statusCallback?()
    } 

    printerConnection.close()
}
}