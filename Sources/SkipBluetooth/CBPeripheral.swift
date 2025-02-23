// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP_BRIDGE
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
    case withResponse = 2
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
    private var _name: String?
    private var _address: String?
    private let stateWatcher = PeripheralStateWatcher { self.state = $0 }

    private var gattDelegate: BleGattCallback?

    internal let device: BluetoothDevice?

    /// Enables us to connect to this peripheral with the underlying Kotlin API
    internal let gatt: BluetoothGatt?

    internal init(result: ScanResult) {
        super.init(macAddress: result.device.address)
        self._name = result.scanRecord?.deviceName
        self._address = result.device.address
        self.device = result.device

        // Although we can get the `BluetoothDevice` from the `ScanResult`
        // we choose not to because in CoreBluetooth we some APIs aren't
        // available until we connect to the device, e.g. `discoverServices`
        self.gatt = nil
    }

    internal init(gatt: BluetoothGatt, gattDelegate: BleGattCallback) {
        super.init(macAddress: gatt.device.address)
        self._name = gatt.device.name
        self._address = gatt.device.address
        self.device = gatt.device
        gattDelegate.peripheral = self

        self.gattDelegate = gattDelegate
        self.gatt = gatt
    }

    open var delegate: (any CBPeripheralDelegate)? {
        get {
            gattDelegate?.peripheralDelegate
        } set {
            gattDelegate?.peripheralDelegate = newValue
        }
    }

    open var name: String? { _name }
    open var address: String? { _address }
    open private(set) var state: CBPeripheralState = CBPeripheralState.disconnected

    open var services: [CBService]? {
        gattDelegate?.services
    }

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

        logger.debug("CBPeripheral.discoverService: discovering services...")
        gatt?.discoverServices();
    }

    @available(*, unavailable)
    open func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for service: CBService) {}

    open func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        service.setCharacteristicFilter(characteristicUUIDs)
        delegate?.peripheralDidDiscoverCharacteristicsFor(self, didDiscoverCharacteristicsFor: service, error: nil)
    }

    open func readValue(for characteristic: CBCharacteristic) {
        gatt?.readCharacteristic(characteristic.kotlin())
    }

    @available(*, unavailable)
    open func maximumWriteValueLength(for type: CBCharacteristicWriteType) -> Int { fatalError() }

    open func writeValue(_ data: Data, for characteristic: CBCharacteristic, type: CBCharacteristicWriteType) {
        logger.debug("CBPeripheral.writeValue: Writing packet:")
        logger.debug("CBPeripheral.writeValue: UUID is \(characteristic.uuid.uuidString)")
        logger.debug("CBPeripheral.writeValue: Data is \(data.base64EncodedString())")
        logger.debug("CBPeripheral.writeValue: Type is \(type)")
        gatt?.writeCharacteristic(characteristic.kotlin(), data.kotlin(), type.rawValue)
    }

    open func setNotifyValue(_ enabled: Bool, for characteristic: CBCharacteristic) {
        guard let gatt = gatt else {
            logger.error("CBPeripheral.setNotifyValue: `gatt` is null which should never happen.")
            return
        }

        guard gatt.setCharacteristicNotification(characteristic.kotlin(), enabled) ?? false else {
            logger.warning("CBPeripheral.setNotifyValue: Failed to setup characteristic subscription")
            return
        }

        guard let descriptor = characteristic.kotlin().getDescriptor(java.util.UUID.fromString(CCCD)) else {
            logger.warning("CBPeripheral.setNotifyValue: Failed to find notification descriptor")
            return
        }

        characteristic.kotlin().setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT)
        let value = enabled ? BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE : BluetoothGattDescriptor.DISABLE_NOTIFICATION_VALUE

        gatt.writeDescriptor(descriptor, value);
    }

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

        override func onConnectionStateChange(gatt: BluetoothGatt, state: Int, newState: Int) {
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
    func peripheralDidUpdateName(_ peripheral: CBPeripheral)
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService])

    @available(*, unavailable)
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: (any Error)?)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?)

    @available(*, unavailable)
    func peripheralDidDiscoverIncludedServicesFor(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: (any Error)?)
    func peripheralDidDiscoverCharacteristicsFor(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?)
    func peripheralDidUpdateValueFor(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?)
    func peripheralDidUpdateNotificationStateFor(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?)

    @available(*, unavailable)
    func peripheralDidDiscoverDescriptorsFor(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: (any Error)?)
    @available(*, unavailable)
    func peripheralDidUpdateValueFor(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: (any Error)?)

    func peripheralDidWriteValueFor(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?)

    @available(*, unavailable)
    func peripheralDidWriteValueFor(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: (any Error)?)

    @available(*, unavailable)
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral)

    @available(*, unavailable)
    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: (any Error)?)
}

public extension CBPeripheralDelegate {
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {}
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {}
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: (any Error)?) {}
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {}

    func peripheralDidWriteValueFor(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {}
    func peripheralDidWriteValueFor(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: (any Error)?) {}
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: (any Error)?) {}
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {}
    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: (any Error)?) {}
    func peripheralDidDiscoverIncludedServicesFor(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: (any Error)?) {}
    func peripheralDidDiscoverCharacteristicsFor(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {}
    func peripheralDidDiscoverDescriptorsFor(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: (any Error)?) {}
    func peripheralDidUpdateNotificationStateFor(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {}
    func peripheralDidUpdateValueFor(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {}
    func peripheralDidUpdateValueFor(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: (any Error)?) {}
}

#endif
#endif

