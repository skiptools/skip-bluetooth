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
