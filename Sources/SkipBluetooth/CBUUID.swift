// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP_BRIDGE
import Foundation

#if SKIP

public let CBUUIDCharacteristicExtendedPropertiesString: String = "2900"
public let CBUUIDCharacteristicUserDescriptionString: String = "2901"
public let CBUUIDClientCharacteristicConfigurationString: String = "2902"
public let CBUUIDServerCharacteristicConfigurationString: String = "2903"
public let CBUUIDCharacteristicFormatString: String = "2904"
public let CBUUIDCharacteristicAggregateFormatString: String = "2905"
public let CBUUIDCharacteristicValidRangeString: String = "2906"

@available(*, unavailable)
public let CBUUIDL2CAPPSMCharacteristicString: String = "2A36"

open class CBUUID: NSObject {
    private lazy var uuid: UUID

    @available(*, unavailable)
    open var data: Data { fatalError() }
    open var uuidString: String {
        uuid.uuidString
    }

    public init(string theString: String) {
        if let uuid = UUID(uuidString: theString) {
            self.uuid = uuid
        } else {
            self.uuid = UUID()
        }
    }

    @available(*, unavailable)
    public init(data theData: Data) { fatalError()}

    @available(*, unavailable)
    public init(cfuuid theUUID: Any) { fatalError() }

    public init(nsuuid: UUID) {
        self.uuid = nsuuid
    }
}

extension CBUUID: KotlinConverting<java.util.UUID> {
    public override func kotlin(nocopy: Bool = false) -> java.util.UUID {
        return uuid.kotlin()
    }
}

extension CBUUID: Equatable {
    public static func == (lhs: CBUUID, rhs: CBUUID) -> Bool {
        return lhs.uuidString == rhs.uuidString
    }
}

#endif
#endif

