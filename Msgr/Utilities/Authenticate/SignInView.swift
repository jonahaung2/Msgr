//
//  AuthenticateSession.swift
//  Myanmar Song Book
//
//  Created by Aung Ko Min on 27/4/22.
//

import SwiftUI

struct SignInView: View {

    @EnvironmentObject private var authenticator: Authenticator
    @State private var viewType = ViewType.SignIn
    @StateObject private var viewModel = SignInViewModel()
    
    var body: some View {
        Form {
            Section {

            } header: {
                AppLogoView()
            } footer: {
                Picker("View Type", selection: $viewType.animation(.spring())) {
                    ForEach(ViewType.allCases, id: \.self) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Section {
                switch viewType {
                case .SignIn:
                    phoneTextField()
                    otpTextField()
                case .Register:
                    phoneTextField()
                    otpTextField()
                }
            } footer: {
                Text(viewModel.infoText)
            }
            .disableAutocorrection(true)

            Section {
                Button(viewType.buttonText) {
                    Task {
                        switch viewType {
                        case .SignIn:
                            await authenticator.signIn(with: viewModel.phoneNumber.trimmed(), viewModel.password)
                        case .Register:
                            await authenticator.register(with: viewModel.phoneNumber.trimmed(), viewModel.password)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(viewModel.phoneNumber.isWhitespace || viewModel.password.isWhitespace )
            } footer: {
                Text(viewModel.infoText)
            }
        }
        .redacted(reason: authenticator.showLoading ? .placeholder : [])
        .navigationBarItems(trailing: trailingItem)
        .alert(authenticator.error, isPresented: $authenticator.showErrorAlert) {
            Button("Ok") { }
        }
        .embeddedInNavigationView()
    }

    private var trailingItem: some View {
        Text("Rest Password")
            .tapToPush(ForgetPasswordView())
    }
    
    private func phoneTextField() -> some View {
        TextField("Mobile Number", text: $viewModel.phoneNumber)
            .textContentType(.telephoneNumber)
            .keyboardType(.phonePad)
    }
    
    private func otpTextField() -> some View {
        SecureField("OTP", text: $viewModel.password)
            .textContentType(.oneTimeCode)
    }

}

extension SignInView {

    enum ViewType: String, CaseIterable {
        case SignIn, Register
        var buttonText: String {
            switch self {
            case .SignIn:
                return "Sign In"
            case .Register:
                return "Register"
            }
        }

        var instructionText: String {
            switch self {
            case .SignIn:
                return "Please enter Mobile Phone Number"
            case .Register:
                return "Please enter staff ID and new password"
            }
        }
    }
}
