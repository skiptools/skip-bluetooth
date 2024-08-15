import Foundation

#if SKIP
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import android.content.pm.PackageManager
import android.Manifest
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts

/// Prompts the user to allow bluetooth permissions
///
/// This process is handled automatically by CoreBluetooth for Swift when you instantiate either
/// `CBCentralManager` or `CBPeripheralManager`, but Android requires the request
/// to occur within an activity.
@Composable
public func askForBluetoothPermissions() {
    let requestPermissionLauncher = rememberLauncherForActivityResult(contract = ActivityResultContracts.RequestMultiplePermissions()) { perms in
        // TODO: toggle bluetooth with another launcher
    }

    let permissions: kotlin.Array<String> = kotlin.arrayOf(
        Manifest.permission.BLUETOOTH_SCAN,
        Manifest.permission.BLUETOOTH_CONNECT,
        Manifest.permission.BLUETOOTH_ADVERTISE,
        Manifest.permission.BLUETOOTH_CONNECT
    )

    // Skip can't implicitly convert between kotlin.Array<string> and
    // skip.lib.Array<String> hence the cast
    SideEffect {
        requestPermissionLauncher.launch(permissions)
    }
}

/// Checks if the given permission is granted
internal func hasPermission(_ permission: String) -> Bool {
    let context = ProcessInfo.processInfo.androidContext
    return context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
}
#endif
