import Foundation

#if SKIP
import android.content.__
import android.content.pm.__
import android.bluetooth.__
import android.bluetooth.le.__
#else
import CoreBluetooth
#endif

#if SKIP
public class CBPeripheralManager: CBManager {
    private var advertiser: BluetoothLeAdvertiser? {
        adapter?.getBluetoothLeAdvertiser()
    }

    @available(*, unavailable)
    public var isAdvertising: Bool = false

    public var delegate: (any CBPeripheralManagerDelegate)?

    public var state: CBManagerState {
        guard let state = adapter?.getState() else {
            return CBManagerState.poweredOff
        }

        switch (state) {
        case (BluetoothAdapter.STATE_ON):
            return CBManagerState.poweredOn
        default:
            return CBManagerState.poweredOff
        }
    }

    public convenience init()

    @available(*, unavailable)
    func startAdvertising(_ advertisementData: [String: Any]?) {
    }

    @available(*, unavailable)
    func stopAdvertising() {

    }

    @available(*, unavailable)
    open func add(_ service: CBMutableService) {}

    @available(*, unavailable)
    open func remove(_ service: CBMutableService) {}

    @available(*, unavailable)
    open func removeAllServices() { }

    @available(*, unavailable)
    public convenience init(delegate: (any CBPeripheralManagerDelegate)?, queue: DispatchQueue?) {}

    @available(*, unavailable)
    public init(delegate: (any CBPeripheralManagerDelegate)?, queue: DispatchQueue?, options: [String : Any]? = nil) {}

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
