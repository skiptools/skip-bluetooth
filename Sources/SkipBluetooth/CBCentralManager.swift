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

// MARK: RECEIVERS
private class FoundDeviceReceiver {
    init(completion: (BluetoothDevice))
}

public enum CBConnectionEvent: Int, @unchecked Sendable {
    case peerDisconnected = 0
    case peerConnected = 1
}

open class CBCentralManager: CBManager {
    private let stateReceiver: BluetoothManagerStateReceiver

    public var delegate: (any CBCentralManagerDelegate)? {
        didSet {
            delegate?.centralManagerDidUpdateState(self)
        }
    }

    public var isScanning: Bool { adapter?.isDiscovering() ?? false }

    public init() {
        self.stateReceiver = BluetoothManagerStateReceiver {
            delegate?.centralManagerDidUpdateState(self)
        }
        let filter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)
        let context = ProcessInfo.processInfo.androidContext
        context.registerReceiver(stateReceiver, filter)
    }

    deinit {
        context.unregisterReceiver(stateReceiver)
    }

    public var state: CBManagerState {
        switch (adapter?.getState()) {
        case (BluetoothAdapter.STATE_ON):
            return CBManagerState.poweredOn
        default:
            return CBManagerState.poweredOff
        }
    }

    public func stopScan() {
        if (!hasPermission(permission: android.Manifest.permission.BLUETOOTH_SCAN)) {
            logger.error("CentralManager.stopScan: Permission error")
            return
        }

        logger.info("CentralManager.stopScan: Stopping Scan")
        adapter?.cancelDiscovery()
    }

#if !SKIP
    open class func supports(_ features: CBCentralManager.Feature) -> Bool

    public convenience init()
    public convenience init(delegate: (any CBCentralManagerDelegate)?, queue: DispatchQueue?)
    public init(delegate: (any CBCentralManagerDelegate)?, queue: dispatch_queue_t?, options: [String : Any]? = nil)
    open func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral]
    open func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral]
    open func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil)
    open func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil)
    open func cancelPeripheralConnection(_ peripheral: CBPeripheral)
    open func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]? = nil)

#endif

    private class BluetoothManagerStateReceiver: BroadcastReceiver {
        private var completion: () -> Void
        init(completion: @escaping () -> Void) {
            self.completion = completion
        }

        override func onReceive(context: Context?, intent: Intent?) {
            if (BluetoothAdapter.ACTION_STATE_CHANGED == intent?.action) {
                let state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)
                completion()
            }
        }
    }
}

#if !SKIP
extension CBCentralManager {
    public struct Feature : OptionSet, @unchecked Sendable {

        public init(rawValue: UInt)

        @available(*, unavailable)
        public static var extendedScanAndConnect: CBCentralManager.Feature { fatalError() }
    }
}
#endif

public protocol CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager)

    #if !SKIP
    optional func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any])
    optional func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    optional func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    optional func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?)
    optional func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?)
    optional func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?)
    optional func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral)
    optional func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral)
    #endif
}

#endif
