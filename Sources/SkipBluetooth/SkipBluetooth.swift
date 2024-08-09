// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import CoreBluetooth

public final class CBCentral: KotlinConverting<android.bluetooth.BluetoothDevice> {
    var maximumUpdateValueLength: Int

    func updateValue(_ value: Data, for characteristic: CBMutableCharacteristic, onSubscribedCentrals centrals: [CBCentral]?) -> Bool {
        // Implementation
    }
}

public final class CBCentralManager: KotlinConverting<android.bluetooth.BluetoothAdapter> {
    var state: CBManagerState

    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?) {
        // Implementation
    }

    func stopScan() {
        // Implementation
    }
}

public protocol CBCentralManagerDelegate: KotlinConverting<android.bluetooth.le.ScanCallback> {
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber)
}

public final class CBService: KotlinConverting<android.bluetooth.BluetoothGattService> {
    var uuid: CBUUID
}

public protocol CBPeripheralDelegate: KotlinConverting<android.bluetooth.BluetoothGattCallback> {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
}

public final class CBPeripheralManager: KotlinConverting<android.bluetooth.BluetoothGattServer> {
    var state: CBManagerState

    func startAdvertising(_ advertisementData: [String: Any]?) {
        // Implementation
    }

    func stopAdvertising() {
        // Implementation
    }
}

public protocol CBPeripheralManagerDelegate: KotlinConverting<android.bluetooth.BluetoothGattServerCallback> {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
}

public final class CBAttribute: KotlinConverting<android.bluetooth.BluetoothGattCharacteristic> {
    var permissions: CBAttributePermissions
}

public final class CBAttributePermissions: KotlinConverting<android.bluetooth.BluetoothGattCharacteristic> {
    var read: Bool
    var write: Bool
}

public final class CBCharacteristic: KotlinConverting<android.bluetooth.BluetoothGattCharacteristic> {
    var properties: Int
    var value: Data?
}

public final class CBMutableCharacteristic: CBCharacteristic {
    var permissions: CBAttributePermissions
}

public final class CBDescriptor: KotlinConverting<android.bluetooth.BluetoothGattDescriptor> {
    var value: Data?
}

public final class CBMutableDescriptor: CBDescriptor {
    var permissions: CBAttributePermissions
}

public final class CBManager: KotlinConverting<android.bluetooth.BluetoothManager> {
    var state: CBManagerState
}

public final class CBATTRequest: KotlinConverting<android.bluetooth.BluetoothGattServerCallback> {
    var characteristic: CBCharacteristic
    var value: Data?
}

public final class CBPeer: KotlinConverting<android.bluetooth.BluetoothDevice> {
    var identifier: UUID
}

public final class CBUUID: KotlinConverting<java.util.UUID> {
    var uuidString: String
}

//public enum CBError: Error, KotlinConverting<android.bluetooth.BluetoothGatt.GATT_*> {
//    case unknown
//    case invalidParameters
//    case invalidHandle
//    // Other cases...
//}

//public enum CBATTError: Error, KotlinConverting<android.bluetooth.BluetoothGatt.GATT_*> {
//    case success
//    case readNotPermitted
//    case writeNotPermitted
//    // Other cases...
//}
//
//public enum CBManagerState: Int, KotlinConverting<android.bluetooth.BluetoothAdapter.STATE_*> {
//    case unknown
//    case resetting
//    case unsupported
//    case unauthorized
//    case poweredOff
//    case poweredOn
//}
#endif
