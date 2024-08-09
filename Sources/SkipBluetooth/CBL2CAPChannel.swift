import Foundation

#if SKIP
public typealias CBL2CAPPSM = UInt16

open class CBL2CAPChannel : NSObject {
    @available(*, unavailable)
    open var peer: CBPeer! { fatalError() }

#if !SKIP
    @available(*, unavailable)
    open var inputStream: InputStream! { fatalError() }

    @available(*, unavailable)
    open var outputStream: OutputStream! { fatalError() }
#endif

    @available(*, unavailable)
    open var psm: CBL2CAPPSM { fatalError() }
}

#endif
