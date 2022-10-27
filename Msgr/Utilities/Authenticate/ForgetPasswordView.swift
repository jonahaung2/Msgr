//
//  ForgetPasswordView.swift
//  Device Monitor
//
//  Created by Aung Ko Min on 3/9/22.
//

import SwiftUI

struct ForgetPasswordView: View {
    @State private var email = ""
    var body: some View {
        Form {
            Section {
                TextField("Email Address", text: $email)
            }
            Section {
                Button("Submit") {
                    
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
