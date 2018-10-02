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
    case systemCancel
    case userFallback
    case passcodeNotSet
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case cannotRetrieveData
    case domainChanged
    case unknown

    public static func initWithError(_ error: LAError) -> BiometricError {        
        switch Int32(error.errorCode) {
        case kLAErrorAuthenticationFailed:
            return authenticationFailed
        case kLAErrorUserCancel:
            return userCancel
        case kLAErrorUserFallback:
            return userFallback
        case kLAErrorSystemCancel:
            return systemCancel
        case kLAErrorPasscodeNotSet:
            return passcodeNotSet
        case kLAErrorBiometryNotAvailable:
            return biometryNotAvailable
        case kLAErrorBiometryNotEnrolled:
            return biometryNotEnrolled
        case kLAErrorBiometryLockout:
            return biometryLockout
        default:
            return unknown
        }
    }
}
