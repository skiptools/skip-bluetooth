# SkipBluetooth

This is a free [Skip](https://skip.tools) Swift/Kotlin library project containing the following modules:

## Implementation Instructions

`SkipBluetooth` aims to provide API parity to `CoreBluetooth`, but in a few cases, this requires using `SKIP DECLARE:` in your implementation.

There are delegate methods which have the same argument type signature (despite having differently-named parameters) in `CoreBluetooth`, and are therefore recognized as the same function to `gradle` since Kotlin doesn't differentiate between function calls based on parameter names. One such collision example is:

```
func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
func centralManager(central: CBCentralManager, DidUpdateANCSAuthorizationFor peripheral: CBPeripheral)
```

in order to implement these functions in your `CBCentralManagerDelegate` implementation, you should write the function call as you would do in Swift, but put the corresponding `// SKIP DECLARE: ...` line above that function which corresponds to the Kotlin-compliant API call.

Here is an example:

```
/* Assuming this function is inside of a class conforming to `CBCentralManagerDelegate` */

// SKIP DECLARE: override fun centralManagerDidConnect(central: CBCentralManager, didConnect: CBPeripheral)
func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    /* Your implementation here */
}
```

Here is a list of all such available functions and their corresponding calls:

**CBCentralManagerDelegate**

| CoreBluetooth                                                                                                             | SkipBluetooth                                                                                                                                       |
| ------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)`                                   | `// SKIP DECLARE: override fun centralManagerDidConnect(central: CBCentralManager, didConnect: CBPeripheral)`                                       |
| `func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral)`                | `// SKIP DECLARE: override fun centralManagerDidUpdateANCSAuthorizationFor(central: CBCentralManager, didUpdateANCSAuthorizationFor: CBPeripheral)` |
| `func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?)` | `// SKIP DECLARE: override fun centralManagerDidDisconnectPeripheral(central: CBCentralManager, peripheral: CBPeripheral, error: (any Error)?)`     |

**CBPeripheralManagerDelegate**

| CoreBluetooth                                                                                                                        | SkipBluetooth                                                                                                                                                  |
| ------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic)`     | `// SKIP DECLARE: override fun peripheralManagerDidSubscribeTo(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo: CBCharacteristic)`         |
| `func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)` | `// SKIP DECLARE: override fun peripheralManagerDidUnsubscribeFrom(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom: CBCharacteristic)` |

**CBPeripheralDelegate**
| CoreBluetooth | SkipBluetooth |
| ------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?)` | `// SKIP DECLARE: override fun peripheralDidUpdateValueFor(peripheral: CBPeripheral, didUpdateValueFor: CBCharacteristic, error: Error?)`
| `func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?)` | `// SKIP DECLARE: override fun peripheralDidWriteValueFor(peripheral: CBPeripheral, didWriteValueFor: CBCharacteristic, error: Error?)` |
| `func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?)` | `// SKIP DECLARE: override fun peripheralDidUpdateNotificationStateFor(peripheral: CBPeripheral, didUpdateNotificationStateFor: CBCharacteristic, error: Error?)` |
| `func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?)` | `// SKIP DECLARE: override fun peripheralDidDiscoverCharacteristicsFor(peripheral: CBPeripheral, didDiscoverCharacteristicsFor: CBService, error: Error?)` |

### Asking for Permissions

Bluetooth requires permissions for both IOS and Kotlin, so you must add the following to your Info.plist file:

- NSBluetoothAlwaysUsageDescription

and these to your AndroidManifest.xml

```
<manifest>
    <!-- What you need generally -->
    <uses-permission android:name="android.permission.BLUETOOTH" />

    <!-- Allows elevated privileges (like turning on and off on android) -->
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />

    <!-- If you want central privileges

    Because you can use bluetooth to discern the user's fine-grained location, you can use this attribute
    to assure that you don't need bluetooth for their location (or remove it and signal your use in the converse)
    -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />

    <!-- If you want peripheral privileges -->
    <uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />

    <!-- If you want to connect in either case -->
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
    <!-- other properties -->
</manifest>
```

> [!IMPORTANT]
> You must request runtime permissions in an `#IF SKIP` block to prevent your app from crashing

Before using any Bluetooth API's, you must request user permissions **in the body of the view or function**
which will use Bluetooth. An example:

```
import SwiftUI

#if SKIP
import SkipBluetooth
#endif

struct ContentView: View {
    var body: some View {
#if SKIP
    askForBluetoothPermissions()
#endif
    }
}

```

This will request Bluetooth permissions as soon as the view appears. Subsequent loads of this view will
not show the prompt again--you will have to request the user to enable Bluetooth in settings.

There may be a better implementation which automatically shows this prompt when `CBCentralManager` or
`CBPeripheralManager` are instantiated as is done in `CoreBluetooth`

## Building

This project is a free Swift Package Manager module that uses the
[Skip](https://skip.tools) plugin to transpile Swift into Kotlin.

Building the module requires that Skip be installed using
[Homebrew](https://brew.sh) with `brew install skiptools/skip/skip`.
This will also install the necessary build prerequisites:
Kotlin, Gradle, and the Android build tools.

## Testing

The module can be tested using the standard `swift test` command
or by running the test target for the macOS destination in Xcode,
which will run the Swift tests as well as the transpiled
Kotlin JUnit tests in the Robolectric Android simulation environment.

Parity testing can be performed with `skip test`,
which will output a table of the test results for both platforms.

```

```
