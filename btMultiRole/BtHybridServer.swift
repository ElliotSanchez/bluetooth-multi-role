import CoreBluetooth

struct BtHybridServer {

    static let shared = SharedBtHybridServer()
}


class SharedBtHybridServer: NSObject {

    var peripheralManager: CBPeripheralManager?
    var centralManager: CBCentralManager?
    var savedPeripherals: [CBPeripheral] = []

    let serviceType = CBUUID(string: "7EE9A244-52CC-41C5-B727-F4271EF5D05A")
    let characteristicType = CBUUID(string: "6A782563-EF1D-4A07-98F7-17E2B0E71F6D")

    func start() {

        //savedPeripherals = []
        peripheralManager = CBPeripheralManager()
        peripheralManager?.delegate = self
    }

    func stop() {

        //stopAdvertisingAndTeardownService()
    }

    fileprivate func setupService(){


        print("\(#function)")
        print("savedPeripherals: \(savedPeripherals)\n")
        peripheralManager?.removeAllServices()

        let service = getAuthService()

        peripheralManager?.add(service)
    }

    fileprivate func getAuthService() -> CBMutableService {

        let authService = CBMutableService(type: serviceType, primary: true)

        var bluetoothCharacteristics: [CBMutableCharacteristic] = []
        bluetoothCharacteristics.append(CBMutableCharacteristic(type: characteristicType, properties: [.notify], value: nil, permissions: .readable))


        authService.characteristics = bluetoothCharacteristics

        return authService
    }
}

extension SharedBtHybridServer: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("\(#function) \(peripheral.state == CBManagerState.poweredOn ? "poweredOn" : "not available")")
        if !savedPeripherals.isEmpty {
            print("savedPeripherals: \(savedPeripherals)\n")
        }

        if peripheral.state == CBManagerState.poweredOn && savedPeripherals.isEmpty {
            setupService()
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        guard error == nil else {
            print("‼️ Unexpected error \(error.debugDescription)")
            return
        }

        print("\(#function) service: 7EE9A244-52CC-41C5-B727-F4271EF5D05A")
        print("peripheralManger.isadvertising = \(peripheralManager?.isAdvertising ?? false ? "true" : "false")")

        centralManager = CBCentralManager()
        centralManager?.delegate = self
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("❇️ \(#function): \(characteristic.uuid.uuidString)")
        print("savedPeripherals: \(savedPeripherals)\n")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("❌ \(#function): \(characteristic.uuid.uuidString)")
        print("savedPeripherals: \(savedPeripherals)\n")
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("🤔 \(#function)")
        print("savedPeripherals: \(savedPeripherals)\n")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {}
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {}

}

extension SharedBtHybridServer: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("\(#function) \(central.state == CBManagerState.poweredOn ? "poweredOn" : "not available")")
        if central.state == CBManagerState.poweredOn {
            print("Starting scanForPeripherals...")
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }

    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        savedPeripherals.append(peripheral)
        guard let advName = advertisementData["kCBAdvDataLocalName"] as? String, advName == "Multi Role" else {
            let _ = savedPeripherals.popLast()
            return
        }

        peripheral.delegate = self as CBPeripheralDelegate
        print("\(#function)")
        print("""

            Found peripheral with name: \(peripheral.name ?? "nil")
                   kCBAdvDataLocalName: \(advName)
            """)

        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {

        print("\(#function)")
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("⚠️ \(#function)")
    }
}

extension SharedBtHybridServer: CBPeripheralDelegate {

}
