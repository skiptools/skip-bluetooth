import Foundation

#if SKIP
import android.content.pm.__
import android.bluetooth.__

public class CBManager {
    let context = ProcessInfo.processInfo.androidContext

    private var bluetoothManager: BluetoothManager? {
        context.getSystemService(BluetoothManager.self.java)
    }

    internal var adapter: BluetoothAdapter? {
        return bluetoothManager?.getAdapter()
    }

    internal func hasPermission(_ permission: String) -> Bool {
        return context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
    }
}
#endif
