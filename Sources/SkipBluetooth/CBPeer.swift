#if SKIP
import SkipFoundation

open class CBPeer: NSObject {
    @available(*, unavailable)
    open var identifier: UUID { fatalError()}
}
#endif
