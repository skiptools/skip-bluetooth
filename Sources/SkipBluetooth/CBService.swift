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
open class CBService {
    fileprivate let service: BluetoothGattService
    private private(set) var characteristicFilter: [CBUUID]? = []

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

    open var characteristics: [CBCharacteristic]? {
        get {
            var result: [CBCharacteristic] = []

            guard characteristicFilter != nil else {
                return Array(service.characteristics.map { CBCharacteristic(platformValue: $0) })
            }

            for uuid in characteristicFilter! {
                if let toAdd = service.getCharacteristic(uuid.kotlin()) {
                    result.append(CBCharacteristic(toAdd))
                }
            }
            return result
        }
    }

    internal init(type UUID: CBUUID, primary isPrimary: Bool) {
        service = BluetoothGattService(UUID.kotlin(), isPrimary ? BluetoothGattService.SERVICE_TYPE_PRIMARY : BluetoothGattService.SERVICE_TYPE_SECONDARY)
    }

    internal init(_ service: BluetoothGattService) {
        self.service = service
    }

    /// Adds a characteristic filter
    ///
    /// This allows us to simulate the effect of discovering characteristics
    /// despite already having all characteristics available after service discovery
    internal func setCharacteristicFilter(_ filter: [CBUUID]?) {
        characteristicFilter = filter
    }
}

public extension CBService: KotlinConverting<BluetoothGattService> {
    public override func kotlin(nocopy: Bool) -> BluetoothGattService {
        return service
    }
}

open class CBMutableService: CBService {
    public init(type UUID: CBUUID, primary isPrimary: Bool) {
        super.init(UUID, isPrimary)
    }

#if !SKIP
    open var includedServices: [CBService]?
#endif

    override open var characteristics: [CBCharacteristic]? {
        get {
            super.characteristics
        } set {
            // TODO: ensure there's no double-adding of services
            for characteristic in newValue ?? [] {
                service.addCharacteristic(characteristic.kotlin())
            }
        }
    }
}

public enum CBManagerState: Int {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}

extension BluetoothGattService {
    func toService() -> CBService {
        CBService(self)
    }
}

#endif
