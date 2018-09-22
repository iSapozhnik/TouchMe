//
//  ViewController.swift
//  TouchMe
//
//  Created by isapozhnik on 09/21/2018.
//  Copyright (c) 2018 isapozhnik. All rights reserved.
//

import UIKit
import TouchMe

struct MyLocalization: BiometricLocalizable {
    var loginReason: String {
        return "Use your finger to login"
    }

    var localizedFallbackTitle: String {
        return "Call support"
    }

    var localizedCancelTitle: String {
        return "Cancel"
    }
}

class PinDefaultsAuthenticationProtected: AuthenticationProtected {
    typealias Data = String

    private var keyName: String {
        return "TouchMe." + String(describing: self)
    }

    var isDataAvailable: Bool {
        return UserDefaults.standard.string(forKey: keyName) != nil ? true : false
    }

    func saveData(data: String, completion: (() -> Void)?) {
        let userDefault = UserDefaults.standard
        userDefault.setValue(data, forKey: keyName)
        userDefault.synchronize()
        completion?()
    }

    func getData(_ completion: (String?) -> Void) {
        let userDefault = UserDefaults.standard
        let data = userDefault.value(forKey: keyName) as? Data
        completion(data)
    }
}

class ViewController: UIViewController {
    var biometricHandler: BiometricHandler<PinDefaultsAuthenticationProtected>?

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var touchIDButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let pinProtected = PinDefaultsAuthenticationProtected()

        biometricHandler = BiometricHandler(authProtected: pinProtected)
        biometricHandler?.localizable = MyLocalization()

        touchIDButton.isHidden = biometricHandler?.protectedDataAvailable != true

        print("Available Biometric type: \(biometricHandler?.biometricType.stringRepresentation)")
        print("Available data: \(biometricHandler?.protectedDataAvailable)")
    }

    @IBAction func save(_ sender: Any) {
        biometricHandler?.authenticateAndSave(textField.text!, completion: { error in
            print("Error is \(error?.localizedDescription ?? "none")")
        })
    }

    @IBAction func touchId(_ sender: Any) {
        authenticateAndGetData()
    }

    private func authenticateAndGetData() {
        biometricHandler?.authenticateAndGetData { [weak self] result in
            switch result {
            case .success(let pin):
                self?.textField.text = pin
            case .failure(let error):
                print("Error is \(error)")
            }
        }
    }
}

