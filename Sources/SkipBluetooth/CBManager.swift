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

    private var bluetoothManager: BluetoothManager? {
        context.getSystemService(BluetoothManager.self.java)
    }

    internal var adapter: BluetoothAdapter? {
        return bluetoothManager?.getAdapter()
    }

    deinit {
        context.unregisterReceiver(stateChangedReceiver)
    }

    internal init() {
        self.stateChangedReceiver = StateChangedReceiver {
            stateChangedHandler?()
        }
        let filter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)
        let context = ProcessInfo.processInfo.androidContext
        context.registerReceiver(stateChangedReceiver, filter)
    }

    private class StateChangedReceiver: BroadcastReceiver {
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
#endif
