import Foundation
import CoreBluetooth

struct BtServer {

    static let shared = SharedBtServer()
}


class SharedBtServer: NSObject {

    var peripheralManager: CBPeripheralManager?

    func start() {

        peripheralManager = CBPeripheralManager()
        peripheralManager?.delegate = self
    }

    func stop() {

        stopAdvertisingAndTeardownService()
    }
}

extension SharedBtServer {

    fileprivate func setupAndAdvertiseService() {

        let uuid = CBUUID(string: "0FFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF0")
        let service = CBMutableService(type: uuid, primary: true)
        let properties = CBCharacteristicProperties.authenticatedSignedWrites
        let permissions = CBAttributePermissions.writeable
        let characteristic = CBMutableCharacteristic(type: uuid, properties: properties, value: nil, permissions: permissions)

        service.characteristics?.append(characteristic)
        peripheralManager?.add(service)

        peripheralManager?.startAdvertising(["NAME" : CBAdvertisementDataLocalNameKey])
    }

    fileprivate func stopAdvertisingAndTeardownService() {

        peripheralManager?.stopAdvertising()
        peripheralManager?.removeAllServices()
    }
}

extension SharedBtServer: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {

        print(String(describing: peripheralManager?.state.rawValue))
        setupAndAdvertiseService()
    }


    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("Advertising - state \(peripheral.state.rawValue)")
    }
}

