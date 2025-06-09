// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
#if !SKIP_BRIDGE
import Foundation

#if SKIP
// CBErrorDomain Constant
public let CBErrorDomain: String = "CBErrorDomain"

// CBError Struct
public struct CBError: CustomNSError, Hashable, Error {
    private let code: Code

    // Error Domain
    public static var errorDomain: String {
        return CBErrorDomain
    }

    // NSError Initialization
    // SKIP @nobridge
    public init(_nsError: NSError) {
        self.code = Code(rawValue: _nsError.code) ?? Code.unknown
    }

    // CBError Code Enumeration
    public enum Code: Int, @unchecked Sendable, Equatable {

        case unknown = 0
        case invalidParameters = 1
        case invalidHandle = 2
        case notConnected = 3
        case outOfSpace = 4
        case operationCancelled = 5
        case connectionTimeout = 6
        case peripheralDisconnected = 7
        case uuidNotAllowed = 8
        case alreadyAdvertising = 9
        case connectionFailed = 10
        case connectionLimitReached = 11
        case unknownDevice = 12
        case operationNotSupported = 13
        case peerRemovedPairingInformation = 14
        case encryptionTimedOut = 15
        case tooManyLEPairedDevices = 16
    }

    // Static properties for each case in CBError.Code
    public static var unknown: CBError.Code { .unknown }
    public static var invalidParameters: CBError.Code { .invalidParameters }
    public static var invalidHandle: CBError.Code { .invalidHandle }
    public static var notConnected: CBError.Code { .notConnected }
    public static var outOfSpace: CBError.Code { .outOfSpace }
    public static var operationCancelled: CBError.Code { .operationCancelled }
    public static var connectionTimeout: CBError.Code { .connectionTimeout }
    public static var peripheralDisconnected: CBError.Code { .peripheralDisconnected }
    public static var uuidNotAllowed: CBError.Code { .uuidNotAllowed }
    public static var alreadyAdvertising: CBError.Code { .alreadyAdvertising }
    public static var connectionFailed: CBError.Code { .connectionFailed }
    public static var connectionLimitReached: CBError.Code { .connectionLimitReached }
    public static var unknownDevice: CBError.Code { .unknownDevice }
    public static var operationNotSupported: CBError.Code { .operationNotSupported }
    public static var peerRemovedPairingInformation: CBError.Code { .peerRemovedPairingInformation }
    public static var encryptionTimedOut: CBError.Code { .encryptionTimedOut }
    public static var tooManyLEPairedDevices: CBError.Code { .tooManyLEPairedDevices }
}

// CBATTErrorDomain Constant
public let CBATTErrorDomain: String = "CBATTErrorDomain"

// CBATTError Struct
public struct CBATTError: CustomNSError, Hashable, Error {
    private let code: Code

    // Error Domain
    public static var errorDomain: String {
        return CBATTErrorDomain
    }

    // NSError Initialization
    // SKIP @nobridge
    public init(_nsError: NSError) {
        self.code = Code(rawValue: _nsError.code) ?? Code.success
    }

    // CBATTError Code Enumeration
    public enum Code: Int, @unchecked Sendable, Equatable {

        case success = 0
        case invalidHandle = 1
        case readNotPermitted = 2
        case writeNotPermitted = 3
        case invalidPdu = 4
        case insufficientAuthentication = 5
        case requestNotSupported = 6
        case invalidOffset = 7
        case insufficientAuthorization = 8
        case prepareQueueFull = 9
        case attributeNotFound = 10
        case attributeNotLong = 11
        case insufficientEncryptionKeySize = 12
        case invalidAttributeValueLength = 13
        case unlikelyError = 14
        case insufficientEncryption = 15
        case unsupportedGroupType = 16
        case insufficientResources = 17
    }

    // Static properties for each case in CBATTError.Code
    @available(iOS 6.0, *)
    public static var success: CBATTError.Code { .success }
    public static var invalidHandle: CBATTError.Code { .invalidHandle }
    public static var readNotPermitted: CBATTError.Code { .readNotPermitted }
    public static var writeNotPermitted: CBATTError.Code { .writeNotPermitted }
    public static var invalidPdu: CBATTError.Code { .invalidPdu }
    public static var insufficientAuthentication: CBATTError.Code { .insufficientAuthentication }
    public static var requestNotSupported: CBATTError.Code { .requestNotSupported }
    public static var invalidOffset: CBATTError.Code { .invalidOffset }
    public static var insufficientAuthorization: CBATTError.Code { .insufficientAuthorization }
    public static var prepareQueueFull: CBATTError.Code { .prepareQueueFull }
    public static var attributeNotFound: CBATTError.Code { .attributeNotFound }
    public static var attributeNotLong: CBATTError.Code { .attributeNotLong }
    public static var insufficientEncryptionKeySize: CBATTError.Code { .insufficientEncryptionKeySize }
    public static var invalidAttributeValueLength: CBATTError.Code { .invalidAttributeValueLength }
    public static var unlikelyError: CBATTError.Code { .unlikelyError }
    public static var insufficientEncryption: CBATTError.Code { .insufficientEncryption }
    public static var unsupportedGroupType: CBATTError.Code { .unsupportedGroupType }
    public static var insufficientResources: CBATTError.Code { .insufficientResources }
}
#endif
#endif

