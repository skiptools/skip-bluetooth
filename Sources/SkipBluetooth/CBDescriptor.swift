// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if !SKIP_BRIDGE
import Foundation

#if SKIP
open class CBDescriptor: CBAttribute {
    @available(*, unavailable)
    open var characteristic: CBCharacteristic? { fatalError() }

    @available(*, unavailable)
    open var value: Any? { fatalError() }

    public init(type UUID: CBUUID, value: Any?) {
        super.init(UUID)
    }

    public init(type UUID: CBUUID) {
        super.init(UUID)
    }
}

open class CBMutableDescriptor: CBDescriptor {
    public override init(type UUID: CBUUID, value: Any?) {
        super.init(UUID)
    }
}

#endif
#endif

