import Foundation

#if SKIP
import android.bluetooth.le.__
import android.bluetooth.__
import android.bluetooth.BluetoothGattCallback

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

internal extension BluetoothGatt {
    var peripheral: CBPeripheral {
        return CBPeripheral(gatt: self)
    }
}

open class CBPeripheral: CBPeer {
    private var _name: String?
    private let stateWatcher = PeripheralStateWatcher { self.state = $0 }
    private let gattDelegate = BleGattCallback(peripheral: self)

    internal let device: BluetoothDevice?

    /// Enables us to connect to this peripheral with the underlying Kotlin API
    internal let gatt: BluetoothGatt?

    internal init(result: ScanResult) {
        self._name = result?.scanRecord.deviceName
        self.device = result?.device

        // Although we can get the `BluetoothDevice` from the `ScanResult`
        // we choose not to because in CoreBluetooth we some APIs aren't
        // available until we connect to the device, e.g. `discoverServices`
        self.gatt = nil
    }

    internal init(gatt: BluetoothGatt) {
        self._name = gatt.device.name
        self.device = gatt.device
        self.gatt = gatt
    }

    open var delegate: (any CBPeripheralDelegate)? {
        get {
            gattDelegate.delegate
        } set {
            gattDelegate.delegate = newValue
        }
    }
    open private(set) var state: CBPeripheralState = CBPeripheralState.disconnected

    @available(*, unavailable)
    open var services: [CBService]? { fatalError() }

    @available(*, unavailable)
    open var canSendWriteWithoutResponse: Bool { fatalError() }

    @available(*, unavailable)
    open var ancsAuthorized: Bool { fatalError() }

    @available(*, unavailable)
    open func readRSSI() {}

    open func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        guard hasPermission(android.Manifest.permission.BLUETOOTH) else {
            logger.debug("CBPeripheral.discoverService: Missing permissions")
        }

        // TODO: Filter services in callback
        gatt?.discoverServices();
    }

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

    private struct BleGattCallback: BluetoothGattCallback {
        private let peripheral: CBPeripheral
        var delegate: CBPeripheralDelegate? {
            didSet {
                delegate = newValue
            }
        }

        init(_ peripheral: CBPeripheral) {
            self.peripheral = peripheral
        }

        override func onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            super.onServicesDiscovered(gatt, status)

            if status != BluetoothGatt.GATT_SUCCESS {
                delegate?.peripheral(peripheral: peripheral, didDiscoverServices: nil)
            } else {
                let error = NSError(domain: "SkipBluetooth", code: status, userInfo: nil)
                delegate?.peripheral(peripheral: peripheral, didDiscoverServices: error)
            }
        }

        override func onCharacteristicRead(gatt: BluetoothGatt, characteristic: BluetoothGattCharacteristic, value: ByteArray, status: Int ) {
            super.onCharacteristicRead(gatt, characteristic, value, status)
        }

        override func onCharacteristicWrite(gatt: BluetoothGatt, characteristic: BluetoothGattCharacteristic, status: Int) {
            super.onCharacteristicWrite(gatt, characteristic, status)
        }
        
        override func onCharacteristicChanged(gatt: BluetoothGatt, characteristic: BluetoothGattCharacteristic, value: ByteArray) {
            super.onCharacteristicChanged(gatt, characteristic, value)
        }
    }
}

public protocol CBPeripheralDelegate : NSObjectProtocol {
    func peripheralDidUpdateName(_ peripheral: CBPeripheral)
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService])
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: (any Error)?)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?)

    #if !SKIP
    optional func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: (any Error)?)
    optional func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: (any Error)?)
    #endif

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: (any Error)?)
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral)
    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: (any Error)?)
}

public extension CBPeripheralDelegate {
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {}
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {}
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: (any Error)?) {}
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {}

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: (any Error)?) {}
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {}
    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: (any Error)?) {}
}

#endif
