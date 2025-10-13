//
//  SendsayError.swift
//  SendsaySDKShared
//
//  Created by Dominik Hadl on 10/05/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation

/// Data types that thrown the possible errors on the configuration object.
public enum SendsayError: LocalizedError {
    /// Sendsay SDK functionality used before configuring the SDK.
    case notConfigured
    /// Unable to configure Sendsay SDK.
    case configurationError(String)
    /// Authorization provided in Configuration is not sufficient to perform the operation.
    case authorizationInsufficient
    /// Uknown error occured, check the description provided.
    case unknownError(String?)
    /// Safety wrapper caught NSException while executing SDK operation.
    case nsExceptionRaised(NonSendableBox<NSException>)
    /// After Sendsay SDK runs into an NSException, further calls to SDK will fail with this exception.
    case nsExceptionInconsistency
    /// Unable to finish an async process
    case stoppedProcess
    /// Property is required but not found
    case missingProperty(property: String)
    /// Property is found but given value type mismatched
    case invalidType(for: String)
    /// Property is found but given value is invalid
    case invalidValue(for: String)
    /// SDK is stopped
    case isStopped

    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return Constants.ErrorMessages.sdkNotConfigured

        case .configurationError(let details):
            return """
            The provided configuration contains error(s). Please, fix them before initialising Sendsay SDK.
            \(details)
            """

        case .authorizationInsufficient:
            return """
            You don't have sufficient authorization to perform this action. Please, double check your
            authorization status.
            """

        case .nsExceptionRaised(let exception):
            return "NSException raised. \(String(describing: exception.value))"

        case .nsExceptionInconsistency:
            return "SendsaySDK ran into NSException, SDK disabled until next run."

        case .unknownError(let details):
            return "Unknown error. \(details ?? "")"

        case .stoppedProcess:
            return "Async process has stopped"
        case .missingProperty(let property): return "Property \(property) is required."
        case .invalidType(let name): return "Invalid type for \(name)."
        case .invalidValue(let name): return "Invalid value for \(name)."
        case .isStopped: return "SDK is stopped."
        }
    }
}

public final class NonSendableBox<T>: @unchecked Sendable { public let value: T; public init(_ value: T) { self.value = value } }
