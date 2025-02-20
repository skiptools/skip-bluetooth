// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP_BRIDGE
#if SKIP

import Foundation
// SKIP @nobridge
public typealias CBL2CAPPSM = UInt16

open class CBL2CAPChannel : NSObject {
    // SKIP @nobridge
    @available(*, unavailable)
    open var peer: CBPeer! { fatalError() }

    // SKIP @nobridge
    @available(*, unavailable)
    open var inputStream: Any! { fatalError() }

    // SKIP @nobridge
    @available(*, unavailable)
    open var outputStream: Any! { fatalError() }

    // SKIP @nobridge
    @available(*, unavailable)
    open var psm: CBL2CAPPSM { fatalError() }
}

#endif
#endif

