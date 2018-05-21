import Foundation
import CoreBluetooth

struct BtServer {

    static let shared = SharedBtServer()
}


class SharedBtServer: NSObject {

    var peripheralManager: CBPeripheralManager?
    let serviceUuid = CBUUID(string: "0FFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF0")
    let characteristicUuid = CBUUID(string: "0FFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFF1")

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

        let service = CBMutableService(type: serviceUuid, primary: true)
        let properties: CBCharacteristicProperties = [CBCharacteristicProperties.write, .notify, .read]
        let permissions: CBAttributePermissions = [.readable, .writeable]
        let characteristic = CBMutableCharacteristic(type: characteristicUuid, properties: properties, value: nil, permissions: permissions)

        var characteristicArray: [CBMutableCharacteristic] = []
        characteristicArray.append(characteristic)
        service.characteristics = characteristicArray
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
        print("\(#function) Request to write \(requests)")
        peripheral.respond(to: requests[0], withResult: CBATTError.success)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        let advertisingData = [CBAdvertisementDataServiceUUIDsKey: [serviceUuid]]
        peripheralManager?.startAdvertising(advertisingData)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("didRecieveRead")

    }
}

