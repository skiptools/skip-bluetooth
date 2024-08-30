#if SKIP
import SkipFoundation

open class CBPeer: NSObject {
    open var identifier: UUID

    required internal init(macAddress: String) {
        // Generate a UUID from the combined info
        identifier = UUID(platformValue:  java.util.UUID.nameUUIDFromBytes(macAddress.toByteArray(Charsets.UTF_8)))
    }
}
#endif
