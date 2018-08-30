import CoreBluetooth

struct Shared {

    static let btHybridServer = SharedBtHybridServer()
}


class SharedBtHybridServer: NSObject {

    var peripheralManager: CBPeripheralManager?
    var centralManager: CBCentralManager?
    var savedPeripherals: [CBPeripheral] = []

    let serviceType = CBUUID(string: "7EE9A244-52CC-41C5-B727-F4271EF5D05A")
    let characteristicType = CBUUID(string: "6A782563-EF1D-4A07-98F7-17E2B0E71F6D")
    let btMultiRoleCentralRestorationKey = "btMultiRoleCBCentralManager"

    let logger = BleEventLogger()

    func start() {
        logger.log("\(#function)")

        peripheralManager = CBPeripheralManager()
        peripheralManager?.delegate = self
    }

    func suspending() {
        logger.log("\(#function)")

        if let peripheral = savedPeripherals.first {
            logger.log("Calling connect on resigning for \(peripheral)...")
            centralManager?.connect(peripheral, options: nil)
        }
    }

    func setupCentralManager() {
        logger.log("\(#function) with attempt to restore...")

        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: btMultiRoleCentralRestorationKey])
    }

    fileprivate func setupService(){

        logger.log("\(#function)")
        logger.log("savedPeripherals: \(savedPeripherals)\n")
        peripheralManager?.removeAllServices()

        let service = getAuthService()

        peripheralManager?.add(service)
    }

    fileprivate func getAuthService() -> CBMutableService {
        logger.log("\(#function)")

        let authService = CBMutableService(type: serviceType, primary: true)

        var bluetoothCharacteristics: [CBMutableCharacteristic] = []
        bluetoothCharacteristics.append(CBMutableCharacteristic(type: characteristicType, properties: [.notify], value: nil, permissions: .readable))


        authService.characteristics = bluetoothCharacteristics

        return authService
    }
}

extension SharedBtHybridServer: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        let peripheralManager = peripheral // unhelpful name from Apple

        logger.log("\(#function) \(peripheralManager.state == CBManagerState.poweredOn ? "poweredOn" : "not available")")

        logger.log("savedPeripherals: \(savedPeripherals.isEmpty ? "isEmpty" : savedPeripherals.description)\n")

        if peripheralManager.state == CBManagerState.poweredOn && savedPeripherals.isEmpty {
            setupService()
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        guard error == nil else {
            logger.log("‼️ Unexpected error \(error.debugDescription)")
            return
        }

        logger.log("peripheralManager didAddService: 7EE9A244-52CC-41C5-B727-F4271EF5D05A")
        logger.log("peripheralManger.isadvertising = \(peripheralManager?.isAdvertising ?? false ? "true" : "false")")

        setupCentralManager()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        logger.log("❇️ \(#function): \(characteristic.uuid.uuidString)")
        logger.log("savedPeripherals: \(savedPeripherals)\n")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        logger.log("❌ \(#function): \(characteristic.uuid.uuidString)")
        logger.log("savedPeripherals: \(savedPeripherals)\n")
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        logger.log("🤔 \(#function)")
        logger.log("savedPeripherals: \(savedPeripherals)\n")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        logger.log("\(#function)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        logger.log("\(#function)")
    }
}

extension SharedBtHybridServer: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let centralManager = central //fix Apple's naming
        logger.log("\(#function) \(centralManager.state == CBManagerState.poweredOn ? "poweredOn" : "not available")")

        guard centralManager.state == CBManagerState.poweredOn else { return }

        if savedPeripherals.isEmpty {
            logger.log("Starting scanForPeripherals because no peripherals are saved...")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else if let peripheral = savedPeripherals.first {
            logger.log("\(#function) - calling connect for \(peripheral)")
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let centralManager = central // fix Apple's naming

        savedPeripherals.append(peripheral)
        guard let advName = advertisementData[CBAdvertisementDataLocalNameKey] as? String, advName == "Multi Role" else {
            let _ = savedPeripherals.popLast()
            return
        }

        peripheral.delegate = self as CBPeripheralDelegate
        logger.log("\(#function)")
        logger.log("""

            Found peripheral with name: \(peripheral.name ?? "nil")
                   kCBAdvDataLocalName: \(advName)
            """)

        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        logger.log("\(#function)")
        savedPeripherals = [peripheral]
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.log("⚠️ \(#function)")
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        logger.log("\(#function)")

        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral], let peripheral = peripherals.first {
            logger.log("ℹ️ Found saved peripheral \(peripheral)")
            savedPeripherals = [peripheral]
            peripheral.delegate = self as CBPeripheralDelegate
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let centralManager = central //fix Apple's naming

        logger.log("\(#function) - calling connect for \(peripheral)")
        //Call connect because we lost connection and want to reconnect as soon as we see it again
        centralManager.connect(peripheral, options: nil)
    }
}

extension SharedBtHybridServer: CBPeripheralDelegate {

    
}

class BleEventLogger {

    func log(_ message: String) {
        NSLog(message)
    }
}
