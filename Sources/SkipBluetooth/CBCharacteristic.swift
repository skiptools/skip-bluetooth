import Foundation

#if SKIP
public struct CBCharacteristicProperties: OptionSet, @unchecked Sendable {
    public let rawValue: Int

    public static let broadcast = CBCharacteristicProperties(rawValue: 1 << 0)

    public static let read = CBCharacteristicProperties(rawValue: 1 << 1)

    public static let writeWithoutResponse = CBCharacteristicProperties(rawValue: 1 << 2)

    public static let write = CBCharacteristicProperties(rawValue: 1 << 3)

    public static let notify = CBCharacteristicProperties(rawValue: 1 << 4)

    public static let indicate = CBCharacteristicProperties(rawValue: 1 << 5)

    public static let authenticatedSignedWrites = CBCharacteristicProperties(rawValue: 1 << 6)

    public static let extendedProperties = CBCharacteristicProperties(rawValue: 1 << 7)

    public static let notifyEncryptionRequired = CBCharacteristicProperties(rawValue: 1 << 8)

    public static let indicateEncryptionRequired = CBCharacteristicProperties(rawValue: 1 << 9)
}

open class CBCharacteristic : CBAttribute {
    @available(*, unavailable)
    open var service: CBService? { fatalError() }

    @available(*, unavailable)
    open var properties: CBCharacteristicProperties { fatalError() }

    @available(*, unavailable)
    open var value: Data? { fatalError() }

    @available(*, unavailable)
    open var descriptors: [CBDescriptor]? { fatalError() }

    @available(*, unavailable)
    open var isBroadcasted: Bool { fatalError() }

    @available(*, unavailable)
    open var isNotifying: Bool { fatalError() }
}

public struct CBAttributePermissions: OptionSet, @unchecked Sendable {
    public let rawValue: Int

    public static let readable = CBAttributePermissions(rawValue: 1 << 0)
    public static let writeable = CBAttributePermissions(rawValue: 1 << 1)
    public static let readEncryptionRequired = CBAttributePermissions(rawValue: 1 << 2)
    public static let writeEncryptionRequired = CBAttributePermissions(rawValue: 1 << 3)
}

open class CBMutableCharacteristic : CBCharacteristic {
    open var permissions: CBAttributePermissions

    @available(*, unavailable)
    open var subscribedCentrals: [CBCentral]? { fatalError() }

    #if !SKIP
    override var properties: CBCharacteristicProperties
    override var value: Data?
    override var descriptors: [CBDescriptor]?
    #endif

    @available(*, unavailable)
    public init(type UUID: CBUUID, properties: CBCharacteristicProperties, value: Data?, permissions: CBAttributePermissions) {fatalError()}
}


#endif
