// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

#if SKIP
import android.bluetooth.BluetoothDevice

open class CBCentral: CBPeer {
    internal let device: BluetoothDevice

    @available(*, unavailable)
    open var maximumUpdateValueLength: Int { fatalError() }
}

extension CBCentral: Equatable {
    public static func == (lhs: CBCentral, rhs: CBCentral) -> Bool {
        lhs.identifier.uuidString == rhs.identifier.uuidString
    }
}

internal extension CBCentral: KotlinConverting<BluetoothDevice> {
    init(platformValue: BluetoothDevice) {
        super.init(macAddress: platformValue.address)
        self.device = platformValue
    }

    override func kotlin(noCopy: Bool) -> BluetoothDevice {
        device
    }
}
#endif
