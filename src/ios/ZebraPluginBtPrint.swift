import Foundation
import ExternalAccessory

@objc(ZebraPluginBtPrint)
class ZebraPluginBtPrint: CDVPlugin {
    var printerConnection: MfiBtPrinterConnection?
    var printer: ZebraPrinter?
    var manager: EAAccessoryManager!
    private var serialNumber: String?
    var isConnected: Bool = false
    
    /**
     Finds a connected printer that matches the specified protocol string.
     This method searches through the connected accessories, identifying any printer that supports the 'com.zebra.rawport' protocol.
     If such a device is found, it attempts to establish a connection with the printer and updates the `serialNumber` property with the device's serial number.
     
     Usage:
     Call this method when  need to find and connect to a Zebra printer. The completion handler will be called with a boolean indicating the success of the operation.
     - Parameter completion: A closure that is called when the printer connection attempt is complete. The closure takes a Boolean parameter, which is `true` if a printer is found and successfully connected; otherwise, `false`.
     NOTE:
     - The method uses 'EAAccessoryManager' to access connected accessories.
     - It only connects to printers that support the 'com.zebra.rawport' protocol.
     - The serial number of the printer is logged if found.
     - The printer need to be already paired with the iOS Device
     */
    @objc func findConnectedPrinter(completion: (Bool) -> Void) {
        let manager = EAAccessoryManager.shared()
        let connectedDevices = manager.connectedAccessories
        for device in connectedDevices {
            if device.protocolStrings.contains("com.zebra.rawport") {
                serialNumber = device.serialNumber
                NSLog("Zebra device found with serial number -> \(serialNumber ?? "N.D")")
                connectToPrinter(completion: { completed in
                    completion(completed)
                })
            }
        }
    }
    
    /**
     Connection to the printer. Start via MfiBtPrinterConnection a new connection
     */
    @objc private func connectToPrinter( completion: (Bool) -> Void) {
        printerConnection = MfiBtPrinterConnection(serialNumber: serialNumber)
        printerConnection?.open()
        completion(true)
    }
    
    /**
     Initializes the printer connection process.
     This method is responsible for initiating the process of finding and connecting to a Zebra printer. It calls `findConnectedPrinter`,
     a method that searches for a connected printer that supports the specified protocol string. If a compatible printer is found and successfully connected,
     the `isConnected` property of the class is updated accordingly.
     */
    @objc func initialize(_ command: CDVInvokedUrlCommand) {
        findConnectedPrinter { [weak self] bool in
            if let strongSelf = self {
                strongSelf.isConnected = bool
            }
        }
    }
    
    /**
     Prints data using a connected Zebra printer. -----  function after adapting code from capacitor to Cordova
     
     This method is responsible for printing data on a Zebra printer. It first checks if the printer is connected. If it is, the method attempts to open the printer connection,
     send the provided data for printing, and then captures the result of the print operation. If the printer is not connected or if any error occurs during the printing process,
     an appropriate error message is generated.
     
     */
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
    
}
