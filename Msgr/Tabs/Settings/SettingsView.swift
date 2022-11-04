//
//  SettingsView.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage(UserDefaultManager.shared.Is_Dark_Mode) private var isDarkMode = false
    @AppStorage(UserDefaultManager.shared.Tint_Color) private var tintColor = TintColor.brown
    @AppStorage(UserDefaultManager.shared.List_Style) private var listStyle = XListStyle.Default
    @AppStorage(UserDefaultManager.shared.UseFaceID) private var useFaceID = true
    @AppStorage(UserDefaultManager.shared.SaveLastVisitedPage) private var saveLastVisitedPage = true

    var body: some View {
        Form {
            Section("User Profile") {
                HStack {
                    Spacer()
                    CachedAsyncImage(url: MockData.userProfilePhotoURL)
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                    Spacer()
                }
                .padding()
            }

            Section {
                FormCell2 {
                    Text("Phone Number")
                } right: {
                    Text(CurrentUser.phone)
                }
                .tapToPush(Text("Edit Staff ID"))

                FormCell2 {
                    Text("Name")
                } right: {
                    Text(CurrentUser.name)

                }.tapToPush(Text("Edit User Name"))
            }

            Section {
                ConfirmButton(title: "Sign Out") {
                    Authenticator.shared.signOut()
                } label: {
                    Text("Sign Out")
                }
                .frame(maxWidth: .infinity)
            }

            Section("Appearancee") {

                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode")
                }

                Picker("Tint Color", selection: $tintColor.animation()) {
                    ForEach(TintColor.allCases, id: \.self) { color in
                        Text(color.rawValue.capitalized)
                            .foregroundColor(color.color)
                            .tag(color)
                    }
                }
                .pickerStyle(.menu)

                Picker("List Style", selection: $listStyle) {
                    ForEach(XListStyle.allCases) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }

                Toggle(isOn: $useFaceID) {
                    Text("Unlock with FaceID")
                }

                Toggle(isOn: $saveLastVisitedPage) {
                    Text("Save Page History")
                }

            }

            Section("Support") {
                Text("End User License")
                    .tapToPush(Text("End User Licens"))
                Text("Terms & Conditions")
                    .tapToPush(Text("Terms & Conditions"))
                Text("Contact US")
                    .tapToPush(Text("Hello World"))
                Text("Rate US")
                    .tapToPush(Text("Hello World"))
                Text("Share App")
                    .tapToPush(Text("Hello World"))
            }

            Section {

            } header: {

            } footer: {
                Text("Version 1.0.0")
            }
        }
        .navigationTitle("Settings")
    }
}
