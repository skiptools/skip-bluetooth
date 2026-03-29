// Copyright 2023–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if !SKIP_BRIDGE
import Foundation

#if SKIP

open class CBPeer {
    open var identifier: UUID

    required internal init(macAddress: String) {
        // Generate a UUID from the combined info
        identifier = UUID(platformValue:  java.util.UUID.nameUUIDFromBytes(macAddress.toByteArray(Charsets.UTF_8)))
    }
}
#endif
#endif

