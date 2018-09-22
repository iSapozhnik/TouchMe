//
//  BiometricAuthenticationType.swift
//  TouchMe
//
//  Created by Ivan Sapozhnik on 21.09.18.
//

import Foundation

public enum BiometricAuthenticationType {
    case faceID
    case touchID
    case notAvailable
}

extension BiometricAuthenticationType {
    public var stringRepresentation: String {
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
