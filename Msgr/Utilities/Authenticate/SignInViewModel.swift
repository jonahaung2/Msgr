//
//  SignInViewModel.swift
//  TL Device Monitor
//
//  Created by Aung Ko Min on 30/8/22.
//

import Foundation
import Firebase
import FirebaseAuth
import CountryPhoneCodeTextField
import FirebaseFirestore

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
    @Published var phone = PhoneNumber.locale
    @Published var otp = ""
    @Published var infoText = ""
    @Published var signInFlow = SignInFlow.PhoneNumber
    @Published var errorText: String?
    @Published var isLoading = false

    func verifyPhoneNumber() {
        isLoading = true
        let formatted = phone.formattedNumber
        PhoneAuthProvider.provider()
          .verifyPhoneNumber(formatted, uiDelegate: nil) {[weak self] verificationID, error in
              guard let self = self else { return }
              self.isLoading = false
              if let error {
                  self.errorText = error.localizedDescription
              } else if let verificationID {
                  UserDefaultManager.shared.authVerificationID = verificationID
                  self.signInFlow = .OTP
              }
          }
    }

    func verifyOTP() {
        guard let verificationID = UserDefaultManager.shared.authVerificationID else { return }
        guard otp.isWhitespace == false else { return }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: otp)
        isLoading = true
        Auth.auth().signIn(with: credential) {[weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error {
                self.errorText = error.localizedDescription
            } else if let result {
                print(result)
                let user = result.user
                self.updateUserToFirestore(user: user)
//                Authenticator.shared.isLoggedIn = true
            }
        }
    }

    private func updateUserToFirestore(user: User) {
        let contact = Contact.Payload(id: user.uid, name: "Aung Ko Min", phone: user.phoneNumber.str, photoURL: "http://www.goodmorningimagesdownload.com/wp-content/uploads/2020/11/Facebook-Profile-Images-65.jpg", pushToken: CurrentUser.pushToken.str)
        
        if let dic = contact.dictionary {
            Firestore.firestore().collection("users").document(contact.id).setData(dic, merge: true) { error in
                if let error {
                    self.errorText = error.localizedDescription
                } else {
                    Authenticator.shared.isLoggedIn = true
                }
            }
        }
    }
    func emailLogin() {
        let email = "jonahaung@gmail.com"
        let password = "111111"
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error  in
            self.isLoading = false
            if let error {
                self.errorText = error.localizedDescription
            } else if let result {
                let user = result.user
                let payload = Contact.Payload(id: user.uid, name: "Jonah Aung", phone: "+6598765432", photoURL: "http://www.goodmorningimagesdownload.com/wp-content/uploads/2020/11/Facebook-Profile-Images-65.jpg", pushToken: CurrentUser.pushToken.str)

                if let dic = payload.dictionary {
                    Firestore.firestore().collection("users").document(payload.id).setData(dic, merge: true) { error in
                        if let error {
                            self.errorText = error.localizedDescription
                        } else {
                            Authenticator.shared.isLoggedIn = true
                        }
                    }
                }
            }
        }
    }
}
