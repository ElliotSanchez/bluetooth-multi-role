import Foundation
import CoreBluetooth

struct BtServer {

    static let shared = SharedBtServer()
}


class SharedBtServer: NSObject {

    var peripheralManager: CBPeripheralManager?
    let uuid = CBUUID(string: "0FFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF0")

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

        let service = CBMutableService(type: uuid, primary: true)
        let properties = CBCharacteristicProperties.authenticatedSignedWrites
        let permissions: CBAttributePermissions = [.readable, .writeable]
        let characteristic = CBMutableCharacteristic(type: uuid, properties: properties, value: Data(bytes: [0x0F, 0x0F]), permissions: permissions)

        service.characteristics?.append(characteristic)
        peripheralManager?.add(service)
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

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("Request to write \(requests)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        let advertisingData = [CBAdvertisementDataServiceUUIDsKey: [uuid]]
        peripheralManager?.startAdvertising(advertisingData)
    }
}

