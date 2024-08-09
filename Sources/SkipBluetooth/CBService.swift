// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import SkipFoundation
import OSLog

#if SKIP
import android.content.__
import android.content.pm.__
import android.bluetooth.__
import android.bluetooth.le.__
#else
import CoreBluetooth
#endif

let logger: Logger = Logger(subsystem: "skip.bluetooth", category: "SkipBluetooth") // adb logcat '*:S' 'skip.bluetooth.SkipBluetooth:V'

#if SKIP
open class CBService: KotlinConverting<BluetoothGattService> {
    private let service: BluetoothGattService

    @available(*, unavailable)
    weak open var peripheral: CBPeripheral? { fatalError() }

    open var isPrimary: Bool { service.type == 0 }
    open var uuid: CBUUID { CBUUID(string: service.uuid.toString()) }

    @available(*, unavailable)
    open var includedServices: [CBService]? {
//        service.includedServices.map({ val in
//          CBService(service: val)
//        })
        fatalError()
    }

    @available(*, unavailable)
    open var characteristics: [CBCharacteristic]? {
        fatalError()
    }

    init(service: BluetoothGattService) {
        self.service = service
    }

    public override func kotlin(nocopy: Bool) -> BluetoothGattService {
        service
    }
}

open class CBMutableService: CBService {
    #if !SKIP
    open var includedServices: [CBService]?
    open var characteristics: [CBCharacteristic]?
    public init(type UUID: CBUUID, primary isPrimary: Bool)
    #endif
}

public enum CBManagerState: Int {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}
#endif
