import Foundation

#if SKIP
open class CBCentral: CBPeer {
    @available(*, unavailable)
    open var maximumUpdateValueLength: Int { fatalError() }
}
#endif
