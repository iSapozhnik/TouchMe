//
//  ToucheMe.swift
//  TouchMe
//
//  Created by Ivan Sapozhnik on 21.09.18.
//

import Foundation
import LocalAuthentication

// MARK: - Interfaces
public protocol BiometricLocalizable {
    var loginReason: String { get }
    var localizedFallbackTitle: String { get }
    var localizedCancelTitle: String { get }
}

public protocol BiometricAuthentication {
    var availableBiometricType: BiometricAuthenticationType { get }
    var localizable: BiometricLocalizable? { get set }

    func evaluatePolicy(_ completion: @escaping (BiometricError?) -> Void)
}

public protocol AuthenticationProtected {
    associatedtype Data

    var isDataAvailable: Bool { get }

    func saveData(data: Data, completion: (() -> Void)?)
    func getData(_ completion: (Data?) -> Void)
}

// MARK: - Localization
private struct DefaultLocalization: BiometricLocalizable {
    var loginReason: String {
        return "Let me in!"
    }

    var localizedFallbackTitle: String {
        return "I will do something else"
    }

    var localizedCancelTitle: String {
        return "Just Cancel"
    }
}

// MARK: - BiometricAuthentication default implementation
public class BiometricAuthenticaticationProvider: BiometricAuthentication {
    public var localizable: BiometricLocalizable?

    public init(with context: LAContext? = nil) {
        self.context = context ?? LAContext()
    }

    private let context: LAContext

    public var availableBiometricType: BiometricAuthenticationType {
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

    public func evaluatePolicy(_ completion: @escaping BiometricCompletion) {
        let handleSuccess = {
            DispatchQueue.main.async {
                completion(nil)
            }
        }

        let handleFailure: (Error?) -> Void = { evaluateError in
            let error = evaluateError?.biometricError()
            DispatchQueue.main.async {
                completion(error)
            }
        }

        let localizable = self.localizable ?? DefaultLocalization()
        context.localizedFallbackTitle = localizable.localizedFallbackTitle
        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = localizable.localizedCancelTitle
        }
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizable.loginReason) { success, evaluateError in
            guard success else {
                handleFailure(evaluateError)
                return
            }

            handleSuccess()
        }
    }
}

// MARK: - Handler
public enum Result<T: AuthenticationProtected> {
    case success(T.Data)
    case failure(BiometricError)
}

public typealias BiometricCompletion = (BiometricError?) -> Void

public class BiometricHandler<T: AuthenticationProtected> {
    public var localizable: BiometricLocalizable? {
        didSet {
            authProvider.localizable = localizable
        }
    }
    public var biometricIDAvailable: Bool {
        return authProvider.availableBiometricType != .notAvailable
    }
    public var biometricType: BiometricAuthenticationType {
        return authProvider.availableBiometricType
    }
    public var protectedDataAvailable: Bool {
        return protectedData?.isDataAvailable ?? false
    }

    private var authProvider: BiometricAuthentication
    private var protectedData: T?

    public init(authProvider: BiometricAuthentication? = nil, authProtected: T? = nil) {
        self.authProvider = authProvider ?? BiometricAuthenticaticationProvider()
        self.protectedData = authProtected
    }

    public func authenticateAndGetData(with protectedData: T,_ completion: @escaping (Result<T>) -> Void) {
        authenticate { error in
            guard error == nil else {
                let result = Result<T>.failure(error!)
                completion(result)
                return
            }

            protectedData.getData { data in
                guard let data = data else {
                    completion(Result<T>.failure(BiometricError.cannotRetrieveData))
                    return
                }
                let result = Result<T>.success(data)
                completion(result)
            }
        }
    }

    public func authenticateAndSaveData(with protectedData: T,_ data: T.Data, completion: @escaping BiometricCompletion) {
        authenticate { error in
            guard error == nil else {
                completion(error)
                return
            }

            protectedData.saveData(data: data, completion: {
                completion(nil)
            })
        }
    }

    public func authenticate(completion: @escaping BiometricCompletion) {
        guard biometricIDAvailable else {
            completion(BiometricError.noBiometricAvailable)
            return
        }

        let handleEvaluation: BiometricCompletion = { error in
            guard let error = error else {
                completion(nil)
                return
            }
            completion(error)
        }

        authProvider.evaluatePolicy(handleEvaluation)
    }
}
