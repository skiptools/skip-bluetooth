// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP_BRIDGE
import Foundation

#if SKIP
import android.os.ParcelUuid
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.bluetooth.BluetoothGattServer
import android.bluetooth.BluetoothGattServerCallback
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothProfile
import android.bluetooth.BluetoothStatusCodes

public enum CBPeripheralManagerConnectionLatency : Int, @unchecked Sendable {
    case low
    case medium
    case high
}

public class CBPeripheralManager: CBManager {
    private let advertiseDelegate = BleAdvertiseCallback(manager: self)
    private let gattServerCallback = BleGattServerCallback(manager: self)

    fileprivate var server: BluetoothGattServer?

    private var advertiser: BluetoothLeAdvertiser? {
        adapter?.getBluetoothLeAdvertiser()
    }

    public var isAdvertising: Bool = false

    public var delegate: (any CBPeripheralManagerDelegate)? {
        didSet {
            logger.debug("CBPeripheralManager.delegate: sending state")
            delegate?.peripheralManagerDidUpdateState(self)
        }
    }

    public convenience init() {
        super.init()

        stateChangedHandler = {
            self.delegate?.peripheralManagerDidUpdateState(self)
        }
    }

    public func cleanup() {
        server?.close()
    }

    public func startAdvertising(_ advertisementData: [String: Any]?) {
        guard hasPermission(android.Manifest.permission.BLUETOOTH_ADVERTISE) else {
            logger.error("CBCentralManager.scanForPeripherals: Missing BLUETOOTH_SCAN permission. Requesting permission...")
            return
        }

        let settingsBuilder = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .setDiscoverable(true)
            .setConnectable(true)
            .setTimeout(0)

        let advertiseDataBuilder = AdvertiseData.Builder()
            .setIncludeDeviceName(true)

        /* NOTE: Apple's CoreBluetooth API only allows you to configure two keys:
         * - CBAdvertisementDataLocalNameKey
         * - CBAdvertisementDataServiceUUIDsKey

         This implementation extends that capability so Apple devices can *receive*
         in-depth information from Android devices despite not being able to transmit it.
         */
        for (key, value) in advertisementData ?? [:] {

            switch key {
            case CBAdvertisementDataLocalNameKey:
                if let localName = value as? String {
                    adapter?.setName(localName)
                }
            case CBAdvertisementDataTxPowerLevelKey:
                if let txPowerLevel = value as? NSNumber {
                    advertiseDataBuilder.setIncludeTxPowerLevel(true)
                }
            case CBAdvertisementDataServiceUUIDsKey:
                // SKIP NOWARN
                if let serviceUUIDs = value as? [CBUUID] {
                    for uuid in serviceUUIDs {
                        advertiseDataBuilder.addServiceUuid(ParcelUuid(uuid.kotlin()))
                    }
                }
            case CBAdvertisementDataServiceDataKey:
                // TODO: Implement - check out https://developer.android.com/reference/android/bluetooth/le/AdvertiseData.Builder#addServiceData(android.os.ParcelUuid,%20byte[])
                break
            case CBAdvertisementDataManufacturerDataKey:
                // TODO: Implement -- check out https://developer.android.com/reference/android/bluetooth/le/AdvertiseData.Builder#addManufacturerData(int,%20byte[])
                break
            case CBAdvertisementDataOverflowServiceUUIDsKey:
                // TODO: Implement
                break
            case CBAdvertisementDataIsConnectable:
                if let isConnectable = value as? NSNumber {
                    settingsBuilder.setConnectable(isConnectable.intValue != 0)
                }
            case CBAdvertisementDataSolicitedServiceUUIDsKey:
                // SKIP NOWARN
                if let solicitedServiceUUIDs = value as? [CBUUID] {
                    for uuid in solicitedServiceUUIDs {
                        advertiseDataBuilder.addServiceSolicitationUuid(ParcelUuid(uuid.kotlin()))
                    }
                }
            default:
                logger.warning("CBPeripheralManager.startAdvertising: Unknown key: $key")
                break
            }
        }

        let settings = settingsBuilder.build()
        let advertiseData = advertiseDataBuilder.build()

        logger.log("CBPeripheralManager.startAdvertising: Begin advertising")
        advertiser?.startAdvertising(settings, advertiseData, advertiseDelegate)
        isAdvertising = true
    }

    public func stopAdvertising() {
        guard hasPermission(android.Manifest.permission.BLUETOOTH_ADVERTISE) else {
            logger.error("CBCentralManager.scanForPeripherals: Missing BLUETOOTH_SCAN permission. Requesting permission...")
            return
        }
        advertiser?.stopAdvertising(advertiseDelegate)
        isAdvertising = false
    }

    open func add(_ service: CBMutableService) {
        if server == nil {
            server = bluetoothManager?.openGattServer(context, gattServerCallback)
        }

        _ = server?.addService(service.kotlin())
    }

    @available(*, unavailable)
    open func remove(_ service: CBMutableService) {}

    open func removeAllServices() {
        server?.clearServices()
    }

    @available(*, unavailable)
    public convenience init(delegate: (any CBPeripheralManagerDelegate)?, queue: DispatchQueue?) {}

    @available(*, unavailable)
    public init(delegate: (any CBPeripheralManagerDelegate)?, queue: DispatchQueue?, options: [String : Any]? = nil) {}

    open func respond(to request: CBATTRequest, withResult result: CBATTError.Code) {
        guard let server = server else {
            logger.error("CBPeripheralManager.respond: Invalid server state")
            return
        }
        server?.sendResponse(
            request.central.kotlin(),
            request.id,
            result.rawValue,
            request.offset,
            request.value?.kotlin()
        )
    }

    open func updateValue(_ value: Data, for characteristic: CBMutableCharacteristic, onSubscribedCentrals centrals: [CBCentral]?) -> Bool {
        guard let server = server else {
            logger.error("CBPeripheralManager.updateValue: Fatal error -- server should never be nil")
            return false
        }
        var ret = BluetoothStatusCodes.SUCCESS

        if centrals == nil {
            for device in bluetoothManager?.getConnectedDevices(BluetoothProfile.GATT_SERVER) ?? [] {
                ret = ret | server.notifyCharacteristicChanged(device, characteristic.kotlin(), characteristic.isNotifying, value.kotlin())
            }
        } else {
            for central in centrals ?? [] {
                ret = ret | server.notifyCharacteristicChanged(central.kotlin(), characteristic.kotlin(), characteristic.isNotifying, value.kotlin())
            }
        }

        logger.debug("CBPeripheralManager.updateValue: Return status is \(ret)")

        return ret == BluetoothStatusCodes.SUCCESS
    }

    @available(*, unavailable)
    open func setDesiredConnectionLatency(_ latency: CBPeripheralManagerConnectionLatency, for central: CBCentral) {}

    @available(*, unavailable)
    open func publishL2CAPChannel(withEncryption encryptionRequired: Bool) {}

    @available(*, unavailable)
    open func unpublishL2CAPChannel(_ PSM: CBL2CAPPSM) {}

    private struct BleAdvertiseCallback: AdvertiseCallback {
        private let manager: CBPeripheralManager

        init(manager: CBPeripheralManager) {
            self.manager = manager
        }

        override func onStartSuccess(settingsInEffect: AdvertiseSettings) {
            manager.delegate?.peripheralManagerDidStartAdvertising(manager, error: nil)
            logger.debug("BleAdvertiseCallback.onStartSuccess: Advertising started successfully")
        }

        override func onStartFailure(errorCode: Int) {
            logger.error("BleAdvertiseCallback.onStartFailure: Advertising failed with error code: $errorCode")
            var description = "Unknown error"
            switch (errorCode) {
            case AdvertiseCallback.ADVERTISE_FAILED_DATA_TOO_LARGE:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Data too large")
                description = "Data too large"
                break
            case AdvertiseCallback.ADVERTISE_FAILED_TOO_MANY_ADVERTISERS:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Too many advertisers")
                description = "Too many advertisers"
                break
            case AdvertiseCallback.ADVERTISE_FAILED_ALREADY_STARTED:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Already started")
                description = "Already started"
                break
            case AdvertiseCallback.ADVERTISE_FAILED_INTERNAL_ERROR:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Internal error")
                description = "Internal error"
                break
            case AdvertiseCallback.ADVERTISE_FAILED_FEATURE_UNSUPPORTED:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Feature unsupported")
                description = "Feature unsupported"
                break
            default:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Unknown error")
                description = "Unknown error"
                break
            }

            let error = NSError("skip.bluetooth", code: errorCode, userInfo: [NSLocalizedDescriptionKey: description])
            manager.delegate?.peripheralManagerDidStartAdvertising(manager, error: error)
        }
    }

    private struct BleGattServerCallback: BluetoothGattServerCallback {
        private let manager: CBPeripheralManager

        init(manager: CBPeripheralManager) {
            self.manager = manager
        }

        override func onDescriptorWriteRequest(
                device: BluetoothDevice,
                requestId: Int,
                descriptor: BluetoothGattDescriptor,
                preparedWrite: Boolean,
                responseNeeded: Boolean,
                offset: Int,
                value: ByteArray
            ) {
                let central = CBCentral(device)
                let characteristic = CBCharacteristic(platformValue: descriptor.characteristic)
                if (descriptor.uuid == UUID.fromString(CCCD)?.kotlin()) {
                    if (value.contentEquals(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)) {
                        logger.debug("BleGattServerCallback.onDescriptorWriteRequest: Client subscribed to notifications for \(characteristic.uuid.uuidString)")
                        manager.delegate?.peripheralManagerDidSubscribeTo(manager, central: central, characteristic)
                    } else {
                        logger.debug("BleGattServerCallback.onDescriptorWriteRequest: Client unsubscribed to notifications for \(characteristic.uuid.uuidString)")
                        manager.delegate?.peripheralManagerDidUnsubscribeFrom(manager, central, characteristic)
                    }

                    // Send a response back to the client
                    writeIfRequested(
                        responseNeeded: responseNeeded,
                        device,
                        requestId,
                        BluetoothGatt.GATT_SUCCESS,
                        offset,
                        value
                    )
                }

                // TODO: Implement other descriptors
                writeIfRequested(
                    responseNeeded: responseNeeded,
                    device,
                    requestId,
                    BluetoothGatt.GATT_FAILURE,
                    offset,
                    value
                )
            }


        override func onCharacteristicReadRequest(device: BluetoothDevice,
                                                  requestId: Int,
                                                  offset: Int,
                                                  characteristic: BluetoothGattCharacteristic) {
            logger.debug("BleGattServerCallback.onCharacteristicReadRequest: Client requested characteristic read")
            logger.debug("BleGattServerCallback.onCharacteristicReadRequest: Characteristic uuid: \(characteristic.uuid.toString())")
            logger.debug("BleGattServerCallback.onCharacteristicReadRequest: Value: \(characteristic.value)")
            let request = CBATTRequest(device, characteristic, offset, nil, requestId)
            manager.delegate?.peripheralManager(manager, didReceiveRead: request)
        }

        override func onCharacteristicWriteRequest(
                device: BluetoothDevice,
                requestId: Int,
                characteristic: BluetoothGattCharacteristic,
                preparedWrite: Boolean,
                responseNeeded: Boolean,
                offset: Int,
                value: ByteArray
        ) {
            let request = CBATTRequest(device, characteristic, offset, value, requestId)
            manager.delegate?.peripheralManager(manager, didReceiveWrite: [request])
        }

        override func onExecuteWrite(device: BluetoothDevice?, requestId: Int, execute: Bool) {
            guard execute else {
                return
            }

            manager?.server?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, nil)
        }

        private func writeIfRequested(
            responseNeeded: Boolean,
            _ device: BluetoothDevice,
            _ requestId: Int,
            _ state: Int,
            _ offset: Int,
            _ value: ByteArray
        ) {
            guard responseNeeded else {
                return
            }

            manager?.server.sendResponse(
                device,
                requestId,
                state,
                offset,
                value
            )
        }
    }
}

public protocol CBPeripheralManagerDelegate : NSObjectProtocol {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)

    @available(*, unavailable)
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any])
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: (any Error)?)

    @available(*, unavailable)
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: (any Error)?)

    func peripheralManagerDidSubscribeTo(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic)
    func peripheralManagerDidUnsubscribeFrom(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest)
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest])

    @available(*, unavailable)
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager)
    @available(*, unavailable)
    func peripheralManagerDidPublishL2CAPChannel(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: (any Error)?)
    @available(*, unavailable)
    func peripheralManagerDidUnpublishL2CAPChannel(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: (any Error)?)
    @available(*, unavailable)
    func peripheralManagerDidOpen(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: (any Error)?)
}

public extension CBPeripheralManagerDelegate {
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {}
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: (any Error)?) {}
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: (any Error)?) {}
    func peripheralManagerDidSubscribeTo(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {}
    func peripheralManagerDidUnsubscribeFrom(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {}
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {}
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {}
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {}
    func peripheralManagerDidPublishL2CAPChannel(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: (any Error)?) {}
    func peripheralManagerDidUnpublishL2CAPChannel(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: (any Error)?) {}
    func peripheralManagerDidOpen(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: (any Error)?) {}
}

#endif
#endif

