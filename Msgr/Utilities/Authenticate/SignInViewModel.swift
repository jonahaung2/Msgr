//
//  SignInViewModel.swift
//  TL Device Monitor
//
//  Created by Aung Ko Min on 30/8/22.
//

import Foundation
import FirebaseAuth


final class SignInViewModel: ObservableObject {

    enum SignInFlow: String, CaseIterable, Identifiable {
        var id: String { rawValue }
        case PhoneNumber, OTP
        var buttonText: String {
            switch self {
            case .PhoneNumber:
                return "Verify Phone Number"
            case .OTP:
                return "Verify OTP"
            }
        }

        var instructionText: String {
            switch self {
            case .PhoneNumber:
                return "Please enter Mobile Phone Number"
            case .OTP:
                return "Please enter SMS OTP sent to your phone"
            }
        }
    }
    

    @Published var phoneNumber = ""
    @Published var otp = ""
    @Published var infoText = ""
    @Published var signInFlow = SignInFlow.PhoneNumber
    @Published var isLoading = false
    @Published var errorText: String?

    func verifyPhoneNumber() {
        guard !phoneNumber.isEmpty else { return }
        isLoading = true
        let formatted = PhoneHelper.getCountryCode() + phoneNumber.trimmingCharacters(in: .whitespaces)
        PhoneAuthProvider.provider()
          .verifyPhoneNumber(formatted, uiDelegate: nil) { verificationID, error in
              if let error {
                  self.isLoading = false
                  self.errorText = error.localizedDescription
                return
              }
              if let verificationID {
                  self.infoText = verificationID
                  UserDefaultManager.shared.authVerificationID = verificationID
                  self.signInFlow = .OTP
              }
              self.isLoading = false
          }
    }

    func verifyOTP() {
        guard let verificationID = UserDefaultManager.shared.authVerificationID else { return }
        guard otp.isWhitespace == false else { return }
        isLoading = true

        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: otp)
        infoText = credential.description

        Auth.auth().signIn(with: credential) { result, error in
            if let error {
                self.isLoading = false
                self.errorText = error.localizedDescription
                return
            }
            if result?.user != nil {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}
