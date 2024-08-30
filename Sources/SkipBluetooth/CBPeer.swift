// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

#if SKIP

open class CBPeer: NSObject {
    open var identifier: UUID

    required internal init(macAddress: String) {
        // Generate a UUID from the combined info
        identifier = UUID(platformValue:  java.util.UUID.nameUUIDFromBytes(macAddress.toByteArray(Charsets.UTF_8)))
    }
}
#endif
