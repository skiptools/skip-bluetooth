// Copyright 2025–2026 Skip
// SPDX-License-Identifier: MPL-2.0
#if !SKIP_BRIDGE
#if SKIP

import Foundation
public typealias CBL2CAPPSM = UInt16

open class CBL2CAPChannel {
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
#endif

