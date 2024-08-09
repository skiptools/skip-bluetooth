import Foundation

#if SKIP
import android.bluetooth.le.__
import android.bluetooth.__

public enum CBPeripheralState : Int, @unchecked Sendable {
    case disconnected = 0
    case connecting = 1
    case connected = 2
    case disconnecting = 3
}

public enum CBCharacteristicWriteType : Int, @unchecked Sendable {
    case withResponse = 0
    case withoutResponse = 1
}

internal extension ScanResult {
    var advertisementData: [String: Any] {
        parseAdvertisementData()
    }

    func toPeripheral() -> CBPeripheral {
        return CBPeripheral(result: self)
    }

    /// Maps the `ScanResult` to `advertisementData` expected from a scan response
    ///
    /// - Note: Some fields are not available in the `ScanResult` object
    ///         - `kCBAdvDataOverflowServiceUUIDs`
    ///         - `kCBAdvDataSolicitedServiceUUIDs`
    ///
    /// The following are unimplemented:
    /// - `CBAdvertisementDataManufacturerDataKey`
    /// - `CBAdvertisementDataIsConnectable`
    ///
    /// - Returns: The `advertisementData`
    private func parseAdvertisementData() -> [String: Any] {
        let advertisementData: [String: Any] = [:]

        if let deviceName = scanRecord?.deviceName {
            advertisementData[CBAdvertisementDataLocalNameKey] = deviceName
        }

        if let txPowerLevel = scanRecord?.txPowerLevel,
           txPowerLevel != Int.MIN_VALUE {
            advertisementData[CBAdvertisementDataTxPowerLevelKey] = txPowerLevel
        }

        if let uuids = scanRecord?.serviceUuids {
            advertisementData[CBAdvertisementDataServiceUUIDsKey] = uuids.map { $0.uuid }
        }

        advertisementData[CBAdvertisementDataIsConnectable] = isConnectable

        // TODO: CBAdvertisementDataServiceDataKey
        // TODO: CBAdvertisementDataManufacturerDataKey

        return advertisementData
    }
}

open class CBPeripheral: CBPeer {
    private var scanResult: ScanResult
    private let stateWatcher = PeripheralStateWatcher { self.state = $0 }

    internal init(result: ScanResult) {
        self.scanResult = result
    }

    weak open var delegate: (any CBPeripheralDelegate)?
    open var name: String? { scanResult?.scanRecord.deviceName }
    open private(set) var state: CBPeripheralState = CBPeripheralState.disconnected

    @available(*, unavailable)
    open var services: [CBService]? { fatalError() }

    @available(*, unavailable)
    open var canSendWriteWithoutResponse: Bool { fatalError() }

    @available(*, unavailable)
    open var ancsAuthorized: Bool { fatalError() }

    @available(*, unavailable)
    open func readRSSI() {}

    @available(*, unavailable)
    open func discoverServices(_ serviceUUIDs: [CBUUID]?) {}

    @available(*, unavailable)
    open func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService) {}

    @available(*, unavailable)
    open func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {}

    @available(*, unavailable)
    open func readValue(for characteristic: CBCharacteristic) {}

    @available(*, unavailable)
    open func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int { fatalError() }

    @available(*, unavailable)
    open func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {}

    @available(*, unavailable)
    open func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {}

    @available(*, unavailable)
    open func discoverDescriptors(for characteristic: CBCharacteristic) {}

    @available(*, unavailable)
    open func readValue(for descriptor: CBDescriptor) {}
    @available(*, unavailable)
    open func writeValue(_ data: Data, for descriptor: CBDescriptor) {}

    @available(*, unavailable)
    open func openL2CAPChannel(_ PSM: CBL2CAPPSM) {}

    private class PeripheralStateWatcher: BluetoothGattCallback {
        private let completion: (CBPeripheralState) -> Void

        init(completion: @escaping (CBPeripheralState) -> Void) {
            self.completion = completion
        }

        override func onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            switch (newState) {
            case BluetoothProfile.STATE_DISCONNECTED:
                logger.debug("CBPeripheral: Device disconnected")
                completion(CBPeripheralState.disconnected)
                break
            case BluetoothProfile.STATE_CONNECTING:
                logger.debug("CBPeripheral: Device connecting")
                completion(CBPeripheralState.connecting)
                break
            case BluetoothProfile.STATE_CONNECTED:
                logger.debug("CBPeripheral: Device connected")
                completion(CBPeripheralState.connected)
                break
            case BluetoothProfile.STATE_DISCONNECTING:
                logger.debug("CBPeripheral: Device disconnecting")
                completion(CBPeripheralState.disconnecting)
                break
            }
        }

    }
}

public protocol CBPeripheralDelegate : NSObjectProtocol {
    optional func peripheralDidUpdateName(_ peripheral: CBPeripheral)
    optional func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService])
    optional func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?)

    #if !SKIP
    optional func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: (any Error)?)
    #endif

    optional func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: (any Error)?)
    optional func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral)
    optional func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: (any Error)?)
}

#endif
