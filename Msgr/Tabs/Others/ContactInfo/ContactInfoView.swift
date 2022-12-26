//
//  ContactInfoView.swift
//  Msgr
//
//  Created by Aung Ko Min on 30/11/22.
//

import SwiftUI

struct ContactInfoView: View {

    @StateObject private var viewModel: ContactInfoViewModel

    init(_ contactID: String) {
        _viewModel = .init(wrappedValue: .init(contactID))
    }

    var body: some View {
        Form {
            Section {
                ContactAvatarView(viewModel.contact, .original, .extraLarge)
            }

            Section {
                FormCell2 {
                    Text("Name")
                } right: {
                    Text(viewModel.contact.name)
                }
                FormCell2 {
                    Text("Phone")
                } right: {
                    Text(.init(viewModel.contact.phoneNumber.str))
                }
                FormCell2 {
                    Text("URL")
                } right: {
                    if let url = URL(string: viewModel.contact.photoUrl.str) {
                        Link(destination: url) {
                            Text("Photo URL")
                        }
                    } else {
                        Text(.init(viewModel.contact.photoUrl.str))
                    }
                }
            }
        }
        .navigationBarTitle("Contact Info", displayMode: .large)
    }
}
