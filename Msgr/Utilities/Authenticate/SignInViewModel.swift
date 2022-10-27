//
//  SignInViewModel.swift
//  TL Device Monitor
//
//  Created by Aung Ko Min on 30/8/22.
//

import Foundation

final class SignInViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var password = ""
    @Published var infoText = ""
}
