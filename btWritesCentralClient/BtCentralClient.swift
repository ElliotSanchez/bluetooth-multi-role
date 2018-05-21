
import Foundation
import CoreBluetooth

struct BtClient {

    static let shared = SharedBtClient()
}


class SharedBtClient: NSObject {

    var centralManager: CBCentralManager?
    let serviceUuid = CBUUID(string: "0FFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF0")
    //let characteristicUuid = CBUUID(string: "0FFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF1")
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
        centralManager?.scanForPeripherals(withServices: [serviceUuid], options: nil)
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

        peripheral.delegate = self
        peripheral.discoverServices([serviceUuid])
    }
}

extension SharedBtClient: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        guard let services = peripheral.services,
            services.count > 0 else {
            print("Empty services")
            return
        }

        print(services)

        peripheral.discoverCharacteristics(nil, for: services[0])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        print(service.characteristics.debugDescription)

        guard let characteristics = service.characteristics else {
            print("No characteristics")
            return
        }

        print("\(#function) - About to attempt overwrite \(service.characteristics?.first?.descriptors?.first?.value.debugDescription)")

        peripheral.readValue(for: characteristics.first!)
        peripheral.writeValue(Data(bytes:[0xEE]), for: characteristics.first!, type: CBCharacteristicWriteType.withResponse)
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("\(#function) - Wrote new value \(descriptor.value.debugDescription)")
        peripheral.readValue(for: descriptor)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("\(#function) - Wrote new value \(descriptor.value.debugDescription)")
        peripheral.readValue(for: descriptor)
    }

    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("\(#function) - Wrote new value \(invalidatedServices.first?.characteristics?.first?.descriptors?.first?.value.debugDescription)")
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("\(#function) - characteristic value \(characteristic.value?.debugDescription)")
    }
}

