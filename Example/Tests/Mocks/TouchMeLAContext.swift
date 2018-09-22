//
//  TouchMeLAContext.swift
//  TouchMe_Tests
//
//  Created by Ivan Sapozhnik on 22.09.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import LocalAuthentication

class TouchMeLAContext: LAContext {
    private var error: Error?

    init(with error: Error? = nil) {
        self.error = error
    }

    @available(iOS 11.0, *)
    override var biometryType: LABiometryType {
        return .touchID
    }
    
    override func evaluatePolicy(_ policy: LAPolicy, localizedReason: String, reply: @escaping (Bool, Error?) -> Void) {
        reply(self.error == nil ? true : false, self.error)
    }
}

@available(iOS 11.0, *)
class TouchMeLAContext_faceID: TouchMeLAContext {
    override var biometryType: LABiometryType {
        return .faceID
    }
}

@available(iOS 11.0, *)
class TouchMeLAContext_touchID: TouchMeLAContext {
    override var biometryType: LABiometryType {
        return .touchID
    }
}

@available(iOS 11.0, *)
class TouchMeLAContext_notAvailable: TouchMeLAContext {
    override var biometryType: LABiometryType {
        return .LABiometryNone
    }
}
