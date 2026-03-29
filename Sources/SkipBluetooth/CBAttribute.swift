// Copyright 2025–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if !SKIP_BRIDGE
import Foundation

#if SKIP
open class CBAttribute {
    open var uuid: CBUUID

    internal init(uuid: CBUUID) {
        self.uuid = uuid
    }
}

extension CBAttribute: Equatable {
    public static func == (lhs: CBAttribute, rhs: CBAttribute) -> Bool {
        return lhs.uuid.uuidString == rhs.uuid.uuidString
    }
}
#endif
#endif

