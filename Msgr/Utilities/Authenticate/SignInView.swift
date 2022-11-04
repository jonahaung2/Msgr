//
//  AuthenticateSession.swift
//  Myanmar Song Book
//
//  Created by Aung Ko Min on 27/4/22.
//

import SwiftUI
import CountryPhoneCodeTextField

struct SignInView: View {

    @StateObject private var viewModel = SignInViewModel()
    
    var body: some View {
        Form {
            Section {

            } footer: {
                Picker("View Type", selection: $viewModel.signInFlow.animation(.spring())) {
                    ForEach(SignInViewModel.SignInFlow.allCases) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Section(footer: Text(viewModel.phone.formattedNumber)) {
                switch viewModel.signInFlow {
                case .PhoneNumber:
                    PhoneNumberTextField(phoneNumber: $viewModel.phone)
                case .OTP:
                    TextField("One Time Pin", text: $viewModel.otp)
                        .textContentType(.oneTimeCode)
                }
            }
            Section {
                Button(viewModel.signInFlow.buttonText) {
                    switch viewModel.signInFlow {
                    case .PhoneNumber:
                        viewModel.verifyPhoneNumber()
                    case .OTP:
                        viewModel.verifyOTP()
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(!viewModel.phone.isValid)

                Button("Email Login") {
                    viewModel.emailLogin()
                }
            }
        }
        .loadiable(viewModel.isLoading)
        .alert(item: $viewModel.errorText){ text in
            Alert(title: Text("Error"), message: Text(text), dismissButton: .cancel())
        }
        .navigationTitle("Sign In")
        .embeddedInNavigationView()
    }
}
