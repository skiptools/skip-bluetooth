// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if !SKIP_BRIDGE
public let CBCentralManagerOptionShowPowerAlertKey: String = "kCBInitOptionShowPowerAlert"
public let CBCentralManagerOptionRestoreIdentifierKey: String = "kCBRestoreIdentifierKey"
public let CBCentralManagerOptionDeviceAccessForMedia: String = "kCBInitOptionDeviceAccessForMedia"
public let CBCentralManagerScanOptionAllowDuplicatesKey: String = "kCBScanOptionAllowDuplicates"
public let CBCentralManagerScanOptionSolicitedServiceUUIDsKey: String = "kCBScanOptionSolicitedServiceUUIDs"
public let CBConnectPeripheralOptionNotifyOnConnectionKey: String = "kCBConnectOptionNotifyOnConnection"
public let CBConnectPeripheralOptionNotifyOnDisconnectionKey: String = "kCBConnectOptionNotifyOnDisconnection"
public let CBConnectPeripheralOptionNotifyOnNotificationKey: String = "kCBConnectOptionNotifyOnNotification"
public let CBConnectPeripheralOptionStartDelayKey: String = "kCBConnectOptionStartDelay"
public let CBConnectPeripheralOptionEnableTransportBridgingKey: String = "kCBConnectOptionEnableTransportBridging"
public let CBConnectPeripheralOptionRequiresANCS: String = "kCBConnectOptionRequiresANCS"
public let CBCentralManagerRestoredStatePeripheralsKey: String = "kCBRestoredStatePeripherals"
public let CBCentralManagerRestoredStateScanServicesKey: String = "kCBRestoredStateScanServices"
public let CBCentralManagerRestoredStateScanOptionsKey: String = "kCBRestoredStateScanOptions"

public struct CBConnectionEventMatchingOption: Hashable, Equatable, RawRepresentable, @unchecked Sendable {
    public var rawValue: String

    public init(rawValue: String) { self.rawValue = rawValue }
}

extension CBConnectionEventMatchingOption {
    public static let serviceUUIDs: CBConnectionEventMatchingOption = CBConnectionEventMatchingOption(rawValue: "kCBConnectionEventMatchingOptionServiceUUIDs")
    public static let peripheralUUIDs: CBConnectionEventMatchingOption = CBConnectionEventMatchingOption(rawValue: "kCBConnectionEventMatchingOptionPeripheralUUIDs")
}

public let CBConnectPeripheralOptionEnableAutoReconnect: String = "kCBConnectOptionEnableAutoReconnect"
#endif

