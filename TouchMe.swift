//
//  TouchMe.swift
//  Pods
//
//  Created by Ivan Sapozhnik on 21.09.18.
//

import Foundation
import LocalAuthentication

protocol BiometricAuthentication {
    var availableBiometricType: BiometricAuthenticationType { get }
    var loginReason: String { get }

    func evaluatePolicy(_ completion: @escaping (BiometricError?) -> Void)
}

protocol AuthenticationProtected {
    associatedtype Data

    var isDataAvailable: Bool { get }

    func saveData(data: Data)
    func getData() -> Data
}

struct LoginData {
    let login: String
    let password: String
}

class LoginAuthenticationProtected: AuthenticationProtected {
    typealias Data = LoginData

    var isDataAvailable: Bool {
        return true
    }

    func saveData(data: LoginData) {
        // save data
    }

    func getData() -> LoginData {
        return LoginData(login: "test", password: "1234")
    }
}

class PinAuthenticationProtected: AuthenticationProtected {
    typealias Data = String

    var isDataAvailable: Bool {
        return true
    }

    func saveData(data: String) {
        // save data
    }

    func getData() -> String {
        return "pin: 1234"
    }
}

class BiometricAuthenticaticationProvider: BiometricAuthentication {
    var loginReason: String {
        return "Let me in!"
    }
    private let context = LAContext()

    var availableBiometricType: BiometricAuthenticationType {
        if #available(iOS 11, *) {
            let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            switch context.biometryType {
            case .none:
                return .notAvailable
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            }
        } else {
            return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .notAvailable
        }
    }

    func evaluatePolicy(_ completion: @escaping (BiometricError?) -> Void) {
        let handleSuccess = {
            DispatchQueue.main.async {
                completion(nil)
            }
        }

        let handleFailure: (Error?) -> Void = { evaluateError in
            let error = BiometricAuthenticaticationProvider.biometricError(from: evaluateError)
            DispatchQueue.main.async {
                completion(error)
            }
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { success, evaluateError in
            guard success else {
                handleFailure(evaluateError)
                return
            }

            handleSuccess()
        }
    }

    private static func biometricError(from error: Error?) -> BiometricError {
        if #available(iOS 11.0, *) {
            return biometricErrorForNewerVersions(error)
        } else {
            return biometricErrorForOlderVersions(error)
        }
    }

    @available(iOS 11.0, *)
    private static func biometricErrorForNewerVersions(_ error: Error?) -> BiometricError {
        switch error {
        case LAError.authenticationFailed?:
            return .authenticationFailed
        //"There was a problem verifying your identity."
        case LAError.userCancel?:
            return .userCancel
        //"You pressed cancel."
        case LAError.userFallback?:
            return .userFallback
        //"You pressed password."
        case LAError.biometryNotAvailable?:
            return .biometryNotAvailable
        //"Face ID/Touch ID is not available."
        case LAError.biometryNotEnrolled?:
            return .biometryNotEnrolled
        //"Face ID/Touch ID is not set up."
        case LAError.biometryLockout?:
            return .biometryLockout
        //"Face ID/Touch ID is locked."
        default:
            return .unknown
            //"Face ID/Touch ID may not be configured"
        }
    }

    private static func biometricErrorForOlderVersions(_ error: Error?) -> BiometricError {
        switch error {
        case LAError.authenticationFailed?:
            return .authenticationFailed
        //"There was a problem verifying your identity."
        case LAError.userCancel?:
            return .userCancel
        //"You pressed cancel."
        case LAError.userFallback?:
            return .userFallback
        //"You pressed password."
        default:
            return .unknown
            //"Face ID/Touch ID may not be configured"
        }
    }
}

enum BiometricAuthenticationType {
    case faceID
    case touchID
    case notAvailable

    var stringRepresentation: String {
        switch self {
        case .faceID:
            return "FaceID"
        case .touchID:
            return "TouchID"
        default:
            return "None"
        }
    }
}

enum BiometricError: Error {
    case noBiometricAvailable
    case authenticationFailed
    case userCancel
    case userFallback
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case unknown
}

class BiometricHandler<T: AuthenticationProtected> {
    var biometricIDAvailable: Bool {
        return authProvider.availableBiometricType != .notAvailable
    }

    private let authProvider: BiometricAuthentication
    private let protectedData: T

    init(with authProvider: BiometricAuthentication, authProtected: T) {
        self.authProvider = authProvider
        self.protectedData = authProtected
    }

    func authenticateAndGetData(completion: @escaping (T.Data?, Error?) -> Void) {
        guard biometricIDAvailable else {
            completion(nil, BiometricError.noBiometricAvailable)
            return
        }

        let handleEvaluation: (BiometricError?) -> Void = { error in
            guard let error = error else {
                completion(self.protectedData.getData(), nil)
                return
            }
            completion(nil, error)
        }

        authProvider.evaluatePolicy(handleEvaluation)
    }
}

