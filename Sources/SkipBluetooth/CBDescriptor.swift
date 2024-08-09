import Foundation

#if SKIP
open class CBDescriptor: CBAttribute {
    @available(*, unavailable)
    open var characteristic: CBCharacteristic? { fatalError() }

    @available(*, unavailable)
    open var value: Any? { fatalError() }
}

open class CBMutableDescriptor: CBDescriptor {
    public init(type UUID: CBUUID, value: Any?) {

    }
}

#endif
