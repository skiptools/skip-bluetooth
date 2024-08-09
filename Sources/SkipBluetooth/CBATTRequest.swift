import Foundation

#if SKIP
open class CBATTRequest : NSObject {
    
    @available(*, unavailable)
    open var central: CBCentral { fatalError() }

    @available(*, unavailable)
    open var characteristic: CBCharacteristic { fatalError() }

    @available(*, unavailable)
    open var offset: Int { fatalError() }

    open var value: Data?
}
#endif
