import Foundation

#if SKIP
import androidx.__
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import android.__
import android.Manifest
import android.app.__
import android.content.pm.__
import android.bluetooth.__
import android.bluetooth.le.__
#else
import CoreBluetooth
#endif

#if SKIP

public enum CBConnectionEvent: Int, @unchecked Sendable {
    case peerDisconnected = 0
    case peerConnected = 1
}

open class CBCentralManager: CBManager {
    private let scanDelegate = BleScanCallback(central: self)
    private let gattDelegate = BleGattCallback(central: self)

    private var scanner: BluetoothLeScanner? {
        adapter?.getBluetoothLeScanner()
    }

    public var delegate: (any CBCentralManagerDelegate)? {
        get {
            gattDelegate.delegate
        } set {
            scanDelegate.delegate = newValue
            gattDelegate.delegate = newValue
        }
    }

    public var isScanning: Bool { adapter?.isDiscovering() ?? false }

    public override init() {
        super.init()
        stateChangedHandler = {
            delegate?.centralManagerDidUpdateState(self)
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

    open func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil) {
        guard hasPermission(android.Manifest.permission.BLUETOOTH_SCAN) else {
            logger.error("CBCentralManager.scanForPeripherals: Missing BLUETOOTH_SCAN permission.")
            return
        }

        // TODO: Use function arguments in scanning
        scanner?.startScan(scanDelegate)
        logger.info("CBCentralManager.scanForPeripherals: Starting Scan")
    }

    public func stopScan() {
        guard hasPermission(android.Manifest.permission.BLUETOOTH_SCAN) else {
            logger.error("CBCentralManager.scanForPeripherals: Missing BLUETOOTH_SCAN permission")
            return
        }

        logger.info("CentralManager.stopScan: Stopping Scan")
        scanner?.stopScan(scanDelegate)
    }

#if !SKIP
    open class func supports(_ features: CBCentralManager.Feature) -> Bool

    public convenience init()
    public convenience init(delegate: (any CBCentralManagerDelegate)?, queue: DispatchQueue?)
    public init(delegate: (any CBCentralManagerDelegate)?, queue: dispatch_queue_t?, options: [String : Any]? = nil)
    open func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral]
    open func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral]
    open func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil)
#endif
    open func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil) {
        guard hasPermission(android.Manifest.permission.BLUETOOTH_CONNECT) else {
            logger.error("CBCentralManager.connect: Missing BLUETOOTH_CONNECT permission.")
            return
        }

        peripheral.device?.connectGatt(context, true, gattDelegate)
    }
#if !SKIP
    open func cancelPeripheralConnection(_ peripheral: CBPeripheral)
    open func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]? = nil)

#endif

    // MARK: NATIVE ANDROID AUXILIARY LOGIC

    private struct BleScanCallback: ScanCallback {
        private let central: CBCentralManager
        var delegate: CBCentralManagerDelegate? {
            didSet {
                delegate?.centralManagerDidUpdateState(central)
            }
        }

        init(central: CBCentralManager) {
            self.central = central
        }

        override func onScanResult(callbackType: Int, result: ScanResult) {
            super.onScanResult(callbackType, result)
            logger.debug("BleScanCallback.onScanResult: \(result.device.name) - \(result.device.address)")

            delegate?.centralManager(central: central, didDiscover: result.toPeripheral(), advertisementData: result.advertisementData, rssi: NSNumber(value: result.rssi))
        }

        @available(*, unavailable)
        override func onBatchScanResults(results: List<ScanResult>) {
            super.onBatchScanResults(results)
            for result in results {
                logger.debug("BleScanCallback.onBatchScanResults: \(result.device.name) - \(result.device.address)")
            }
        }

        override func onScanFailed(errorCode: Int) {
            super.onScanFailed(errorCode)
            logger.warning("BleScanCallback.onScanFailed: Scan failed with error: \(errorCode)")
        }
    }

    /// Handles behavior for calling `CBCentralManagerDelegate` callbacks after a connection has been established
    private struct BleGattCallback: BluetoothGattCallback {
        private let central: CBCentralManager
        var delegate: CBCentralManagerDelegate?

        init(central: CBCentralManager) {
            self.central = central
        }

        override func onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            super.onConnectionStateChange(gatt, status, newState)
            if status == BluetoothGatt.GATT_SUCCESS {
                if newState == BluetoothProfile.STATE_CONNECTED {
                    delegate?.centralManagerDidConnect(central: central, peripheral: gatt.peripheral)
                }
            } else {
                logger.debug("GattCallback.onConnectionStateChange: state is \(status)")
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
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any])
#endif
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)

    // SKIP INSERT: fun centralManagerDidConnect(central: CBCentralManager, peripheral: CBPeripheral) { return }

#if !SKIP
    // SKIP DECLARE: fun centralManagerDidFailToDisconnect(central: CBCentralManager, peripheral: CBPeripheral, error: (any Error)?)
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?)

    // SKIP DECLARE: fun centralManagerDidDisconnectPeripheral(central: CBCentralManager, peripheral: CBPeripheral, error: (any Error)?)
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?)
#endif

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?)
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral)
    
    // SKIP INSERT: fun centralManagerDidUpdateANCSAuthorizationFor(central: CBCentralManager, peripheral: CBPeripheral) { return }
}

public extension CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) { return }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?) { return }
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) { return }
}

#endif
