// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP_BRIDGE
import Foundation

#if SKIP
import androidx.__
import android.__
import android.content.IntentFilter
import android.content.Intent
import android.content.Context
import android.content.BroadcastReceiver
import android.Manifest
import android.app.__
import android.content.pm.__
import android.bluetooth.__
import android.bluetooth.le.__
import android.os.ParcelUuid

public enum CBConnectionEvent: Int, @unchecked Sendable {
    case peerDisconnected = 0
    case peerConnected = 1
}

open class CBCentralManager: CBManager {
    private let scanDelegate = BleScanCallback(central: self)
    private let gattDelegate = BleGattCallback(central: self)

    private lazy var bondingReceiver: BondCallback! = BondCallback { device in
        tryConnect(to: device)
    }

    // TODO: Allow multiple connections at a time
    private var pendingGatts: BluetoothGatt?

    private var scanner: BluetoothLeScanner? {
        adapter?.getBluetoothLeScanner()
    }

    public var delegate: (any CBCentralManagerDelegate)? {
        get {
            gattDelegate.centralManagerDelegate
        } set {
            scanDelegate.delegate = newValue
            gattDelegate.centralManagerDelegate = newValue
        }
    }

    public var isScanning: Bool { adapter?.isDiscovering() ?? false }

    public convenience init() {
        super.init()

        stateChangedHandler = {
            delegate?.centralManagerDidUpdateState(self)
        }

        bondingReceiver = BondCallback { device in
            tryConnect(to: device)
        }

        let filter = IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
        let context = ProcessInfo.processInfo.androidContext
        context.registerReceiver(bondingReceiver, filter)
    }

    // SKIP @nobridge
    @available(*, unavailable)
    public convenience init(delegate: (any CBCentralManagerDelegate)?, queue: DispatchQueue?) { fatalError() }

    // SKIP @nobridge
    @available(*, unavailable)
    public init(delegate: (any CBCentralManagerDelegate)?, queue: DispatchQueue, options: [String : Any]? = nil) { fatalError() }

    open func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil) {
        guard hasPermission(android.Manifest.permission.BLUETOOTH_SCAN) else {
            logger.error("CBCentralManager.scanForPeripherals: Missing BLUETOOTH_SCAN permission.")
            return
        }

        let settingsBuilder = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_BALANCED)
            .setCallbackType(ScanSettings.CALLBACK_TYPE_FIRST_MATCH)
        let filterBuilder = ScanFilter.Builder()

        if let serviceUUIDs = serviceUUIDs {
            for uuid in serviceUUIDs {
                filterBuilder.setServiceUuid(ParcelUuid(uuid.kotlin()))
            }
        }

        if let isDuplicate = options?[CBCentralManagerScanOptionAllowDuplicatesKey] as? Bool {
            settingsBuilder.setCallbackType(
                isDuplicate ? ScanSettings.CALLBACK_TYPE_ALL_MATCHES : ScanSettings.CALLBACK_TYPE_FIRST_MATCH
            )
        }

        // SKIP NOWARN
        if let uuids = options?[CBCentralManagerScanOptionSolicitedServiceUUIDsKey] as? [CBUUID] {
            for uuid in uuids {
                filterBuilder.setServiceSolicitationUuid(ParcelUuid(uuid.kotlin()))
            }
        }

        let settings = settingsBuilder.build()
        let scanFilters = listOf(filterBuilder.build())

        scanner?.startScan(scanFilters, settings, scanDelegate)
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

    @available(*, unavailable)
    open class func supports(_ features: CBCentralManager.Feature) -> Bool { fatalError() }

    @available(*, unavailable)
    open func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral] { fatalError() }

    @available(*, unavailable)
    open func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBUUID]) -> [CBPeripheral] { fatalError() }

    open func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil) {
        guard hasPermission(android.Manifest.permission.BLUETOOTH_CONNECT) else {
            logger.error("CBCentralManager.connect: Missing BLUETOOTH_CONNECT permission.")
            return
        }
        guard let device = peripheral.device else {
            logger.error("CBCentralManager.connect: Peripheral has no device.")
            return
        }

        logger.log("CBCentralManager.connect: Connecting to \(peripheral.device)")
        logger.log("CBCentralManager.connect: pendingGatts = \(pendingGatts)")
        tryConnect(to: device)
    }
    open func cancelPeripheralConnection(_ peripheral: CBPeripheral) {
        peripheral?.gatt.disconnect()
        peripheral?.gatt.close()
    }

    @available(*, unavailable)
    open func registerForConnectionEvents(options: [CBConnectionEventMatchingOption : Any]? = nil) { }

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

    private class BondCallback: BroadcastReceiver {
        private let completion: (BluetoothDevice) -> Void
        init(completion: @escaping (BluetoothDevice) -> Void) {
            self.completion = completion
        }

        override func onReceive(context: Context?, intent: Intent?) {
            let action = intent?.action
            switch (action) {
            case BluetoothDevice.ACTION_BOND_STATE_CHANGED:
                let device = intent?.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice.self.java)
                let bondState = intent?.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.ERROR)
                switch (bondState) {
                case BluetoothDevice.BOND_BONDED:
                    guard let device = device else {
                        logger.error("BondCallback.onReceive: Device is nil")
                        return
                    }

                    logger.debug("StateChangedReceiver: Bonded with \(device?.name ?? "nil")")
                    completion(device)
                    break
                case BluetoothDevice.BOND_BONDING:
                    logger.debug("StateChangedReceiver: Bonding in progress.")
                    break
                case BluetoothDevice.BOND_NONE:
                    logger.debug("StateChangedReceiver: Bonding failed or broken")
                    break
                default:
                    break
                }
            }
        }
    }
}

// MARK: Private functions
extension CBCentralManager {
    func tryConnect(to device: BluetoothDevice) {
        logger.log("CBCentralManager.connect: connecting!")
        pendingGatts = device.connectGatt(context, false, gattDelegate, BluetoothDevice.TRANSPORT_LE)
    }
}

extension CBCentralManager {
    public struct Feature : OptionSet, @unchecked Sendable {
        // SKIP @nobridge
        public let rawValue: UInt

        // SKIP @nobridge
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        @available(*, unavailable)
        public static var extendedScanAndConnect: CBCentralManager.Feature { fatalError() }
    }
}

public protocol CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager)

    @available(*, unavailable)
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any])
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)

    func centralManagerDidConnect(central: CBCentralManager, peripheral: CBPeripheral)

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?)
    func centralManagerDidDisconnectPeripheral(_ central: CBCentralManager, peripheral: CBPeripheral, error: (any Error)?)

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?)
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral)

    @available(*, unavailable)
    func centralManagerDidUpdateANCSAuthorizationFor(central: CBCentralManager, peripheral: CBPeripheral)
}

public extension CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) { return }
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {}
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime, isReconnecting: Bool, error: (any Error)?) { return }
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) { return }
    func centralManagerDidConnect(central: CBCentralManager, peripheral: CBPeripheral) { return }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) { return }
    func centralManagerDidUpdateANCSAuthorizationFor(central: CBCentralManager, peripheral: CBPeripheral) { return }
    func centralManagerDidDisconnectPeripheral(_ central: CBCentralManager, peripheral: CBPeripheral, error: (any Error)?) { }
}

#endif
#endif

