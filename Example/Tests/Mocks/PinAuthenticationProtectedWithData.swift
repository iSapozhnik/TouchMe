//
//  PinAuthenticationProtectedWithData.swift
//  TouchMe_Tests
//
//  Created by Ivan Sapozhnik on 22.09.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import TouchMe

class PinAuthenticationProtectedWithData: AuthenticationProtected {
    typealias Data = String

    var isDataAvailable: Bool {
        return true
    }

    func saveData(data: String, completion: (() -> Void)?) {
        completion?()
    }

    func getData(_ completion: (String) -> Void) {
        completion(Config.expectedPinString)
    }
}
