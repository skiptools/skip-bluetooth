import Foundation

#if SKIP
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothDevice

open class CBATTRequest : NSObject {
    
    open private(set) var central: CBCentral

    open private(set) var characteristic: CBCharacteristic

    open private(set) var offset: Int

    open var value: Data?
}

internal extension CBATTRequest: Identifiable {
    var id: Int

    init(device: BluetoothDevice,
         characteristic: BluetoothGattCharacteristic,
         offset: Int,
         value: ByteArray?,
         id: Int
    )
    {
        self.id = id
        self.central = CBCentral(platformValue: device)
        self.characteristic = CBCharacteristic(platformValue: characteristic)
        self.offset = offset
        self.value = value == nil ? nil : Data(platformValue: value!)
    }
}

extension CBATTRequest: CustomStringConvertible {
    open var description: String {
        return "CBATTRequest(id: \(id), central: \(central), characteristic: \(characteristic), offset: \(offset), value: \(value))"
    }
}

#endif
