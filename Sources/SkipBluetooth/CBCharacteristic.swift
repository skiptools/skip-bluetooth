// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

import Foundation

#if SKIP
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor

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
    internal var characteristic: BluetoothGattCharacteristic

    internal init(type UUID: CBUUID, properties: CBCharacteristicProperties, permissions: CBAttributePermissions) {
        super.init(UUID)
        self.characteristic = BluetoothGattCharacteristic(UUID.kotlin(), properties.rawValue, permissions.rawValue)

        // Setup notifications if needed
        if properties.contains(.notify) || properties.contains(.indicate) {
            let cccd = BluetoothGattDescriptor(
                java.util.UUID.fromString(CCCD),
                BluetoothGattDescriptor.PERMISSION_READ | BluetoothGattDescriptor.PERMISSION_WRITE
            )
            characteristic.addDescriptor(cccd)
        }
    }

    internal init(platformValue: BluetoothGattCharacteristic) {
        super.init(uuid: CBUUID(string: platformValue.uuid.toString()))
        characteristic = platformValue
    }

    internal init(platformValue: BluetoothGattCharacteristic, value: Data) {
        self.init(platformValue: platformValue)
        self.value = value
    }

    @available(*, unavailable)
    open var service: CBService? { fatalError() }

    @available(*, unavailable)
    open var properties: CBCharacteristicProperties { fatalError() }

    open private(set) var value: Data?

    @available(*, unavailable)
    open var descriptors: [CBDescriptor]? { fatalError() }

    @available(*, unavailable)
    open var isBroadcasted: Bool { fatalError() }

    open private(set) var isNotifying: Bool = false

    internal func setIsNotifying(to isNotifying: Boolean) {
        self.isNotifying = isNotifying
    }
}

public extension CBCharacteristic: KotlinConverting<BluetoothGattCharacteristic> {
    public override func kotlin(nocopy: Bool) -> BluetoothGattCharacteristic {
        return characteristic
    }
}

public struct CBAttributePermissions: OptionSet, @unchecked Sendable {
    public let rawValue: Int

    public static let readable = CBAttributePermissions(rawValue: 1 << 0)
    public static let readEncryptionRequired = CBAttributePermissions(rawValue: 1 << 1)
    public static let writeable = CBAttributePermissions(rawValue: 1 << 4)
    public static let writeEncryptionRequired = CBAttributePermissions(rawValue: 1 << 5)
}

open class CBMutableCharacteristic: CBCharacteristic {

    open var permissions: CBAttributePermissions

    @available(*, unavailable)
    open var subscribedCentrals: [CBCentral]? { fatalError() }

#if !SKIP
    override var properties: CBCharacteristicProperties
    override var value: Data?
    override var descriptors: [CBDescriptor]?
#endif

    public init(type UUID: CBUUID, properties: CBCharacteristicProperties, value: Data?, permissions: CBAttributePermissions) {
        /* TODO: Handle the case where value is not nil
         In this case, this characteristic isn't dynamic, and you should cache the response as described here:
         https://developer.apple.com/documentation/corebluetooth/cbmutablecharacteristic/init(type:properties:value:permissions:)
         */
        super.init(type: UUID, properties: properties, permissions: permissions)
    }
}
#endif
