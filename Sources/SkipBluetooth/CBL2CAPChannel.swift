// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP

import Foundation
public typealias CBL2CAPPSM = UInt16

open class CBL2CAPChannel : NSObject {
    @available(*, unavailable)
    open var peer: CBPeer! { fatalError() }

    @available(*, unavailable)
    open var inputStream: Any! { fatalError() }

    @available(*, unavailable)
    open var outputStream: Any! { fatalError() }

    @available(*, unavailable)
    open var psm: CBL2CAPPSM { fatalError() }
}

#endif
