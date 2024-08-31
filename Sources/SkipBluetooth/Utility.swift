// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

#if SKIP
import android.content.pm.PackageManager
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothProfile

// MARK: Globals
let CCCD = "00002902-0000-1000-8000-00805f9b34fb"

/// Checks if the given permission is granted
internal func hasPermission(_ permission: String) -> Bool {
    let context = ProcessInfo.processInfo.androidContext
    return context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
}

/// Handles behavior for calling `CBCentralManagerDelegate`and `CBPeripheralDelegate` callbacks after a connection has been established
internal class BleGattCallback: BluetoothGattCallback {
    private let central: CBCentralManager

    private(set) var services: [CBService]?

    internal var peripheral: CBPeripheral?

    var centralManagerDelegate: CBCentralManagerDelegate?
    var peripheralDelegate: CBPeripheralDelegate?

    init(central: CBCentralManager) {
        self.central = central
    }

    // MARK: CBCentralManagerDelegate equivalent functions
    override func onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
        if status == BluetoothGatt.GATT_SUCCESS {
            if newState == BluetoothProfile.STATE_CONNECTED {
                logger.debug("GattCallback.onConnectionStateChange: Connected!")
                centralManagerDelegate?.centralManagerDidConnect(central, CBPeripheral(gatt, self))
            } else {
                logger.debug("GattCallback.onConnectionStateChange: Successfully disconnected!")
                centralManagerDelegate?.centralManagerDidDisconnectPeripheral(central, CBPeripheral(gatt, self), nil)
            }
        } else {
            logger.debug("GattCallback.onConnectionStateChange: status is \(status)")
            let error = NSError(domain: "skip.bluetooth", code: 1, userInfo: [NSLocalizedDescriptionKey: "Central manager failed to connect with. Status: \(status)"])
            centralManagerDelegate?.centralManager(central, didFailToConnect: CBPeripheral(gatt, self), error: error)
        }
    }

    // MARK: CBPeripheralDelegate equivalent functions
    override func onServicesDiscovered(gatt: BluetoothGatt, state: Int) {
        guard let peripheral = peripheral else {
            logger.warning("BleGattCallback.onServicesDiscovered: Improper API usage -- peripheral must be set")
            return
        }

        if state == BluetoothGatt.GATT_SUCCESS {
            logger.debug("BleGattCallback.onServicesDiscovered: successfully discovered services")
            let services = gatt.services.map { $0.toService() }
            self.services = Array(services)
            peripheralDelegate?.peripheral(peripheral, nil)
        } else {
            logger.debug("BleGattCallback.onServicesDiscovered: failed to discover services")
            let error = NSError(domain: "skip.bluetooth", code: state, userInfo: nil)
            peripheralDelegate?.peripheral(peripheral: peripheral, didDiscoverServices: error)
        }
    }

    override func onCharacteristicRead(gatt: BluetoothGatt, characteristic: BluetoothGattCharacteristic, value: ByteArray, state: Int ) {
        guard let peripheral = peripheral else {
            logger.warning("BluetoothGattCallback.onCharacteristicsRead: Improper API usage -- peripheral must be set")
            return
        }
        let APPLE_GENERAL_ERROR = 241

        let cbCharacteristic = CBCharacteristic(platformValue: characteristic, value: Data(value))
        logger.debug("BluetoothGattCallback.onCharacteristicRead: Characteristic read \(characteristic.uuid)")

        if state == APPLE_GENERAL_ERROR {
            peripheralDelegate?.peripheralDidUpdateValueFor(
                peripheral,
                didUpdateValueFor: cbCharacteristic,
                error: NSError(domain: "skip.bluetooth", code: state, userInfo: nil)
            )
        } else {
            peripheralDelegate?.peripheralDidUpdateValueFor(
                peripheral,
                didUpdateValueFor: cbCharacteristic,
                error: nil
            )
        }
    }

    override func onCharacteristicWrite(gatt: BluetoothGatt, characteristic: BluetoothGattCharacteristic, state: Int) {
        guard let peripheral = peripheral else {
            logger.warning("BluetoothGattCallback.onCharacteristicsWrite: Improper API usage -- peripheral must be set")
            return
        }

        guard state != BluetoothGatt.GATT_SUCCESS else {
            logger.debug("BluetoothGattCallback.onCharacteristicsWrite: Successfully wrote to peripheral")
            peripheralDelegate?.peripheralDidWriteValueFor(peripheral, didWriteValueFor: CBCharacteristic(platformValue: characteristic), error: nil)
            return
        }


        let error = NSError(domain: "skip.bluetooth", code: state, userInfo: [NSLocalizedDescriptionKey: "Write to peripheral failed"])

        logger.error("BluetoothGattCallback.onCharacteristicsWrite: Failed to write to peripheral with error: \(error)")
        peripheralDelegate?.peripheralDidWriteValueFor(peripheral, didWriteValueFor: CBCharacteristic(platformValue: characteristic), error: error)
    }

    override func onDescriptorRead(gatt: BluetoothGatt, descriptor: BluetoothGattDescriptor, state: Int, value: ByteArray) {
        guard let peripheral = peripheral else {
            logger.warning("BluetoothGattCallback.onDescriptorRead: Improper API usage -- peripheral must be set")
            return
        }

        let cbCharacteristic = CBCharacteristic(platformValue: descriptor.characteristic)

        guard state == BluetoothGatt.GATT_SUCCESS else {
            logger.debug("BluetoothGattCallback.onDescriptorRead: Failed to read from peripheral")
            return
        }

        if (descriptor.uuid == java.util.UUID.fromString(CCCD)) {
            if (value.contentEquals(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)) {
                logger.debug("BluetoothGattCallback.onDescriptorWrite: Successfully subscribed to characteristic")
                cbCharacteristic.setIsNotifying(to: true)
            } else {
                logger.debug("BluetoothGattCallback.onDescriptorWrite: Successfully unsubscribed from characteristic")
                cbCharacteristic.setIsNotifying(to: false)
            }

            peripheralDelegate?.peripheralDidUpdateNotificationStateFor(
                peripheral,
                didUpdateNotificationStateFor: cbCharacteristic,
                error: nil
            )
        }
    }

    override func onDescriptorWrite(gatt: BluetoothGatt, descriptor: BluetoothGattDescriptor, state: Int) {
        guard let peripheral = peripheral else {
            logger.warning("BluetoothGattCallback.onDescriptorWrite: Improper API usage -- peripheral must be set")
            return
        }

        let value = descriptor.value
        let cbCharacteristic = CBCharacteristic(platformValue: descriptor.characteristic)

        guard state == BluetoothGatt.GATT_SUCCESS else {
            logger.debug("BluetoothGattCallback.onDescriptorWrite: Failed to write to peripheral")
            peripheralDelegate?.peripheralDidWriteValueFor(peripheral, didWriteValueFor: cbCharacteristic, error: NSError(domain: "skip.bluetooth", code: state, userInfo: nil))
            return
        }

        if (descriptor.uuid == java.util.UUID.fromString(CCCD)) {
            logger.debug("BluetoothGattCallback.onDescriptorWrite: Notification state changed")
            gatt?.readDescriptor(descriptor)
        } else {
            logger.debug("BluetoothGattCallback.onCharacteristicsChanged: Descriptor changed \(descriptor.uuid)")
        }
    }

    override func onCharacteristicChanged(gatt: BluetoothGatt, characteristic: BluetoothGattCharacteristic, value: ByteArray) {
        guard let peripheral = peripheral else {
            logger.warning("BluetoothGattCallback.onCharacteristicsChanged: Improper API usage -- peripheral must be set")
            return
        }

        let cbCharacteristic = CBCharacteristic(platformValue: characteristic, value: Data(value))
        logger.debug("BluetoothGattCallback.onCharacteristicsChanged: Characteristic changed \(characteristic.uuid)")
        peripheralDelegate?.peripheralDidUpdateValueFor(
            peripheral,
            didUpdateValueFor: cbCharacteristic,
            error: nil
        )
    }
}

#endif
