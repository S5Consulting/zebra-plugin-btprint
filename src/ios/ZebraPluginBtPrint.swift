import Foundation
import ExternalAccessory
import CoreBluetooth
import UIKit

@objc(ZebraPluginBtPrint)
class ZebraPluginBtPrint: CDVPlugin {
    var printerConnection: MfiBtPrinterConnection?
    var printer: ZebraPrinter?
    var manager: EAAccessoryManager!
    private var serialNumber: String?
    var isConnected: Bool = false
    
    // BluetoothManagement
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?

    // PeripheralManagement
    var peripherals: [CBPeripheral] = []
    var alertController: UIAlertController?
    
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
        var deviceConnected = false
        for device in connectedDevices {
            if device.protocolStrings.contains("com.zebra.rawport") {
                serialNumber = device.serialNumber
                deviceConnected = true
                NSLog("Zebra device found with serial number -> \(serialNumber ?? "N.D")")
                connectToPrinter(completion: { completed in
                    completion(completed)
                })
            }
        }
        if(!deviceConnected){
            initializeBluetooth()
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
        
        if(connectedPeripheral != nil){
            printToConnectedPeripheral(data: cpcl, peripheral: self.connectedPeripheral!)
            return
        }
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
    
    
    /// ------------ NEW BLUETOOTH MANAGEMENT ---------
    func initializeBluetooth(){
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        self.showDeviceSelectionModal()
    }
    
}


extension ZebraPluginBtPrint: CBCentralManagerDelegate, CBPeripheralDelegate{
  
    /// ----------------------- BLUETOOTH MANAGEMENT -----------------------

    // bluetooth status listener
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            if central.state == .poweredOn {
                NSLog("Bluetooth on")
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
        }
        
    // Found new peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        // check for zq610 printer and update modal
        if let name = peripheral.name, name.contains("ZQ610") {
            updateAlertWithPeripheral(peripheral)
        }
        NSLog("Peripheral founded: \(peripheral.identifier.uuid) \(peripheral.name)")
    // Autoconnect if macaddress are available
    //if let macAddress = printerMACAddress, peripheral.identifier.uuidString == macAddress {
    //  connectedPeripheral = peripheral
    //  centralManager.stopScan()
    //  centralManager.connect(peripheral, options: nil)
    //}
    }
    
    // Connected to peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("Connesso alla stampante: \(peripheral.name) \(peripheral.services)")
        peripheral.delegate = self
        self.connectedPeripheral = peripheral
        // Check with service uuid
        //peripheral.discoverServices([serviceUUID])
    }

    // Disconnect from peripheral
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NSLog("Disconnesso dalla stampante: \(peripheral.name)")
        connectedPeripheral = nil
    }
    
    
    /// ----------------------- DIALOG MANAGEMENT -----------------------
    
    func showDeviceSelectionModal() {
        
        alertController = UIAlertController(title: "Select a device", message: "Select a ZQ610 Zebra printer", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Annulla", style: .cancel) { _ in
            self.alertController = nil // Resetta il riferimento quando l'alert viene chiuso
        }
        alertController?.addAction(cancelAction)
        
        self.viewController.present(alertController!, animated: true, completion: nil)
    }

    func updateAlertWithPeripheral(_ peripheral: CBPeripheral) {
        guard let name = peripheral.name, name.contains("ZQ610"), let alert = alertController else {
            return
        }
        
        if !alert.actions.contains(where: { $0.title == name }) {
            let action = UIAlertAction(title: name, style: .default, handler: { _ in
                self.connectToPeripheral(peripheral)
            })
            alert.addAction(action)
        }
    }
    
    func connectToPeripheral(_ peripheral:CBPeripheral){
        NSLog("Connessione per Nome")
        connectedPeripheral = peripheral
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
        printToConnectedPeripheral(data: "pippobaudo", peripheral: self.connectedPeripheral!)
    }
    
    // print data
    
    // Funzione per stampare una volta connessa alla periferica
    private func printToConnectedPeripheral(data: String, peripheral: CBPeripheral) {
      NSLog("Start Print....")
        guard let services = peripheral.services else {return }
        let characteristic = services[0].characteristics?[0]
        if(characteristic != nil) {
            let dataToPrint = Data(data.utf8)
            peripheral.writeValue(dataToPrint, for: characteristic!, type: .withoutResponse)
        }
    }
}
