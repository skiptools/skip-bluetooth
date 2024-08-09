import Foundation

#if SKIP
open class CBAttribute: NSObject {

    @available(*, unavailable)
    open var uuid: CBUUID { fatalError() }
}
#endif
