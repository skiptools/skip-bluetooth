// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
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

    // SKIP @nobridge
    override func kotlin(noCopy: Bool) -> BluetoothDevice {
        device
    }
}
#endif
#endif

