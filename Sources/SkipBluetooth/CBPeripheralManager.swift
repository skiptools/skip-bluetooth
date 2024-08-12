import Foundation

#if SKIP
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothAdapter
import android.content.Context
#else
import CoreBluetooth
#endif

#if SKIP
public class CBPeripheralManager: CBManager {
    private let advertiseDelegate = BleAdvertiseCallback(manager: self)

    private var advertiser: BluetoothLeAdvertiser? {
        adapter?.getBluetoothLeAdvertiser()
    }

    @available(*, unavailable)
    public var isAdvertising: Bool = false

    public var delegate: (any CBPeripheralManagerDelegate)? {
        didSet {
            logger.debug("CBPeripheralManager.delegate: sending state")
            delegate?.peripheralManagerDidUpdateState(self)
        }
    }

    public var state: CBManagerState {
        switch (adapter?.getState()) {
        case BluetoothAdapter.STATE_ON:
            return CBManagerState.poweredOn
        default:
            return CBManagerState.poweredOff
        }
    }

    public convenience init() {
        super.init()

        stateChangedHandler = {
            self.delegate?.peripheralManagerDidUpdateState(self)
        }
    }

    public func startAdvertising(_ advertisementData: [String: Any]?) {
        // TODO: Use arguments to configure settings
        guard hasPermission(android.Manifest.permission.BLUETOOTH_ADVERTISE) else {
            logger.error("CBCentralManager.scanForPeripherals: Missing BLUETOOTH_SCAN permission. Requesting permission...")
            return
        }

        let settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setConnectable(true)
            .setTimeout(0)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .build()

        let advertiseData = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .build()

        advertiser?.startAdvertising(settings, advertiseData, advertiseDelegate)
    }

    func stopAdvertising() {
        guard hasPermission(android.Manifest.permission.BLUETOOTH_ADVERTISE) else {
            logger.error("CBCentralManager.scanForPeripherals: Missing BLUETOOTH_SCAN permission. Requesting permission...")
            return
        }

        advertiser?.stopAdvertising(advertiseDelegate)
    }

    @available(*, unavailable)
    open func add(_ service: CBMutableService) {}

    @available(*, unavailable)
    open func remove(_ service: CBMutableService) {}

    @available(*, unavailable)
    open func removeAllServices() { }

    #if !SKIP
    @available(*, unavailable)
    public convenience init(delegate: (any CBPeripheralManagerDelegate)?, queue: DispatchQueue?) {}

    @available(*, unavailable)
    public init(delegate: (any CBPeripheralManagerDelegate)?, queue: DispatchQueue?, options: [String : Any]? = nil) {}
    #endif

    @available(*, unavailable)
    open func respond(to request: CBATTRequest, withResult result: CBATTError.Code) {}

#if !SKIP
    @available(*, unavailable)
    open func updateValue(_ value: Data, for characteristic: CBMutableCharacteristic, onSubscribedCentrals centrals: [CBCentral]?) -> Bool {}

    @available(*, unavailable)
    open class func authorizationStatus() -> CBPeripheralManagerAuthorizationStatus {}

    @available(*, unavailable)
    open func setDesiredConnectionLatency(_ latency: CBPeripheralManagerConnectionLatency, for central: CBCentral) {}

    @available(*, unavailable)
    open func publishL2CAPChannel(withEncryption encryptionRequired: Bool) {}

    @available(*, unavailable)
    open func unpublishL2CAPChannel(_ PSM: CBL2CAPPSM) {}
#endif

    private struct BleAdvertiseCallback: AdvertiseCallback {
        private let manager: CBPeripheralManager

        init(manager: CBPeripheralManager) {
            self.manager = manager
        }

        override func onStartSuccess(settingsInEffect: AdvertiseSettings) {
            super.onStartSuccess(settingsInEffect)
            logger.debug("BleAdvertiseCallback.onStartSuccess: Advertising started successfully")
        }

        override func onStartFailure(errorCode: Int) {
            super.onStartFailure(errorCode)
            logger.error("BleAdvertiseCallback.onStartFailure: Advertising failed with error code: $errorCode")
            switch (errorCode) {
            case AdvertiseCallback.ADVERTISE_FAILED_DATA_TOO_LARGE:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Data too large")
                break
            case AdvertiseCallback.ADVERTISE_FAILED_TOO_MANY_ADVERTISERS:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Too many advertisers")
                break
            case AdvertiseCallback.ADVERTISE_FAILED_ALREADY_STARTED:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Already started")
                break
            case AdvertiseCallback.ADVERTISE_FAILED_INTERNAL_ERROR:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Internal error")
                break
            case AdvertiseCallback.ADVERTISE_FAILED_FEATURE_UNSUPPORTED:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Feature unsupported")
                break
            default:
                logger.error("BleAdvertiseCallback.onStartFailure: Failed: Unknown error")
                break
            }
        }
    }

}

public protocol CBPeripheralManagerDelegate : NSObjectProtocol {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)

    #if !SKIP
    optional func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any])
    optional func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: (any Error)?)
    optional func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: (any Error)?)
    optional func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic)
    optional func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    optional func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest)
    optional func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest])
    optional func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager)
    optional func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: (any Error)?)
    optional func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: (any Error)?)
    optional func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: (any Error)?)
    #endif
}


#endif
