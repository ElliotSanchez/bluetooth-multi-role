
import Foundation
import CoreBluetooth

struct BtClient {

    static let shared = SharedBtClient()
}


class SharedBtClient: NSObject {

    var centralManager: CBCentralManager?
    let uuid = CBUUID(string: "0FFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF0")
    var peripherals: [CBPeripheral] = []

    func start() {

        centralManager = CBCentralManager()
        centralManager?.delegate = self
    }

    func stop() {

        stopSearchingForService()
    }
}

extension SharedBtClient {

    fileprivate func searchAndWriteToService() {
        centralManager?.scanForPeripherals(withServices: [uuid], options: nil)
    }

    fileprivate func stopSearchingForService() {

        centralManager?.stopScan()
    }
}

extension SharedBtClient: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        print(String(describing: centralManager?.state.rawValue))
        searchAndWriteToService()
    }


    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        peripherals.append(peripheral)
        centralManager?.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        let properties = CBCharacteristicProperties.authenticatedSignedWrites
//        let permissions: CBAttributePermissions = [.readable, .writeable]
//        let characteristic = CBMutableCharacteristic(type: uuid, properties: properties, value: nil, permissions: permissions)

        peripheral.discoverServices([uuid])

//        let characteristic = peripheral.services?.first(where: { $0.characteristics?.first?.uuid == uuid })?.characteristics?.first
//        peripheral.writeValue(Data(), for: characteristic!, type: CBCharacteristicWriteType.withResponse)
    }



}

