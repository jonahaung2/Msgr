//
//  Authenticator.swift
//  Myanmar Song Book
//
//  Created by Aung Ko Min on 27/4/22.
//

import SwiftUI
import LocalAuthentication
import FirebaseAuth
import FirebaseAuthCombineSwift
import Combine

class Authenticator: ObservableObject {

    static let shared = Authenticator()

    @Published var showLoading = false
    @Published var isUnlocked = false
    @Published var error: String?

    @Published var isLoggedIn = Auth.auth().currentUser != nil
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Auth.auth()
            .authStateDidChangePublisher()
            .receive(on: RunLoop.main)
            .sink {[weak self] user in
                guard let self else { return }
                self.isLoggedIn = user != nil
                if let user {
                    CurrentUser.shared.observe(user: user)
                } else {
                    CurrentUser.shared.unObserve()
                }
            }
            .store(in: &cancellables)
    }

    func signOut() {
        CurrentUser.shared.unObserve()
        do {
            try Auth.auth().signOut()
        } catch {
            Log(error)
        }
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "We need to unlock your data."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, authenticationError in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if success {
                        HapticsEngine.shared.playSuccess()
                        self.isUnlocked = true
                    } else {
                        if let error {
                            self.error = self.evaluatePolicyFailErrorMessageForLA(errorCode: error.code)
                        } else {
                            self.isUnlocked = true
                        }
                    }
                }
            }
        } else {
            if let error {
                self.error = evaluatePolicyFailErrorMessageForLA(errorCode: error.code)
            }
        }
    }


    private func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        switch errorCode {
        case LAError.authenticationFailed.rawValue:
            return "The user failed to provide valid credentials"
        case LAError.appCancel.rawValue:
            return "Authentication was cancelled by application"
        case LAError.invalidContext.rawValue:
            return "The context is invalid"
        case LAError.notInteractive.rawValue:
            return "Not interactive"
        case LAError.passcodeNotSet.rawValue:
            return "Passcode is not set on the device"
        case LAError.systemCancel.rawValue:
            return "Authentication was cancelled by the system"
        case LAError.userCancel.rawValue:
            return "The user did cancel"
        case LAError.userFallback.rawValue:
            return "The user chose to use the fallback"
        default:
            return evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
    }

    private func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        switch errorCode {
        case LAError.biometryNotAvailable.rawValue:
            return "Authentication could not start because the device does not support biometric authentication."
        case LAError.biometryLockout.rawValue:
            return "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
        case LAError.biometryNotEnrolled.rawValue:
            return "Authentication could not start because the user has not enrolled in biometric authentication."
        default:
            return "Did not find error code on LAError object"
        }
    }

}
