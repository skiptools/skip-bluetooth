// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP_BRIDGE
import Foundation

#if SKIP
open class CBAttribute: NSObject, Equatable {
    open var uuid: CBUUID

    internal init(uuid: CBUUID) {
        self.uuid = uuid
    }

    static func == (lhs: CBAttribute, rhs: CBAttribute) -> Bool {
        return lhs.uuid.uuidString == rhs.uuid.uuidString
    }
}
#endif
#endif

