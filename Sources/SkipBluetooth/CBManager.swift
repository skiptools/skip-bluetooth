// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP_BRIDGE
import Foundation

#if SKIP
import android.content.IntentFilter
import android.content.Intent
import android.content.Context
import android.content.pm.PackageManager
import android.content.BroadcastReceiver
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothAdapter

public class CBManager {
    let context = ProcessInfo.processInfo.androidContext
    private let stateChangedReceiver: StateChangedReceiver
    internal var stateChangedHandler: (() -> Void)?

    internal var bluetoothManager: BluetoothManager? {
        context.getSystemService(BluetoothManager.self.java)
    }

    internal var adapter: BluetoothAdapter? {
        return bluetoothManager?.getAdapter()
    }

    public var state: CBManagerState {
        switch (adapter?.getState()) {
        case BluetoothAdapter.STATE_ON:
            return CBManagerState.poweredOn
        default:
            return CBManagerState.poweredOff
        }
    }

    @available(*, unavailable)
    open class var authorization: CBManagerAuthorization { fatalError() }

    internal init() {
        self.stateChangedReceiver = StateChangedReceiver {
            stateChangedHandler?()
        }
        let filter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)
        let context = ProcessInfo.processInfo.androidContext
        context.registerReceiver(stateChangedReceiver, filter)
    }

    deinit {
        context.unregisterReceiver(stateChangedReceiver)
    }

    private class StateChangedReceiver: BroadcastReceiver {
        private var completion: () -> Void
        init(completion: @escaping () -> Void) {
            self.completion = completion
        }

        override func onReceive(context: Context?, intent: Intent?) {
            let action = intent?.action
            switch (action) {
            case BluetoothAdapter.ACTION_STATE_CHANGED:
                if let state = intent?.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR) {
                    completion()
                } else {
                    logger.error("CBManager.StateChangedReceiver.onReceive: Unknown state")
                }
                break
            default:
                logger.error("StateChangedReceiver: Unknown intent action: \(action ?? "nil")")
                break
            }
        }
    }
}

public enum CBManagerState: Int {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}

public enum CBManagerAuthorization : Int, @unchecked Sendable {
    case notDetermined
    case restricted
    case denied
    case allowedAlways
}

#endif
#endif

