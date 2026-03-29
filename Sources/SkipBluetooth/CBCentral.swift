// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
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

extension CBCentral: KotlinConverting<android.bluetooth.BluetoothDevice> {
    internal init(platformValue: BluetoothDevice) {
        super.init(macAddress: platformValue.address)
        self.device = platformValue
    }

    // SKIP @nooverride
    public override func kotlin(noCopy: Bool) ->  android.bluetooth.BluetoothDevice {
        device
    }
}
#endif
#endif

