//
//  PinAuthenticationProtectedWithoutData.swift
//  TouchMe_Tests
//
//  Created by Ivan Sapozhnik on 22.09.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import TouchMe

class PinAuthenticationProtectedWithoutData: AuthenticationProtected {
    typealias Data = String

    var isDataAvailable: Bool {
        return false
    }

    func saveData(data: String, completion: (() -> Void)?) {
        completion?()
    }

    func getData(_ completion: (String?) -> Void) {
        completion(nil)
    }
}
