//
//  Error.swift
//  TouchMe
//
//  Created by Ivan Sapozhnik on 21.09.18.
//

import Foundation
import LocalAuthentication

public enum BiometricError: Error {
    case noBiometricAvailable
    case authenticationFailed
    case userCancel
    case userFallback
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case cannotRetrieveData
    case unknown
}

extension Error {
    func biometricError() -> BiometricError {
        if #available(iOS 11.0, *) {
            return biometricErrorForNewerVersions()
        } else {
            return biometricErrorForOlderVersions()
        }
    }

    @available(iOS 11.0, *)
    private func biometricErrorForNewerVersions() -> BiometricError {
        switch self {
        case LAError.authenticationFailed:
            return .authenticationFailed
        //"There was a problem verifying your identity."
        case LAError.userCancel:
            return .userCancel
        //"You pressed cancel."
        case LAError.userFallback:
            return .userFallback
        //"You pressed password."
        case LAError.biometryNotAvailable:
            return .biometryNotAvailable
        //"Face ID/Touch ID is not available."
        case LAError.biometryNotEnrolled:
            return .biometryNotEnrolled
        //"Face ID/Touch ID is not set up."
        case LAError.biometryLockout:
            return .biometryLockout
        //"Face ID/Touch ID is locked."
        default:
            return .unknown
            //"Face ID/Touch ID may not be configured"
        }
    }

    private func biometricErrorForOlderVersions() -> BiometricError {
        switch self {
        case LAError.authenticationFailed:
            return .authenticationFailed
        //"There was a problem verifying your identity."
        case LAError.userCancel:
            return .userCancel
        case LAError.userFallback:
            return .userFallback
        default:
            return .unknown
            //"Face ID/Touch ID may not be configured"
        }
    }
}
