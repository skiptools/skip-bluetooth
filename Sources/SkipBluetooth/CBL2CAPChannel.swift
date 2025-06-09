// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
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

