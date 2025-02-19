// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP_BRIDGE
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
        super.init(UUID)
    }
}

#endif
#endif

