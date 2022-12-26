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
    @EnvironmentObject private var currentUser: CurrentUser

    var body: some View {
        Form {
            Section("User Profile") {
                HStack {
                    Spacer()
                    ContactAvatarView(currentUser.payload, .original, .custom(150))
                    Spacer()
                }
                .padding()
            }

            Section {
                FormCell2 {
                    Text("Name")
                } right: {
                    TextField("Name", text: $currentUser.payload.name)
                        .onSubmit {
                            currentUser.update()
                        }
                }
                FormCell2 {
                    Text("Phone Number")
                } right: {
                    Text(currentUser.payload.phone)
                }

                FormCell2 {
                    Text("Photo URL")
                } right: {
                    TextField("URL", text: $currentUser.payload.photoURL ?? .constant(""))
                        .onSubmit {
                            currentUser.update()
                        }
                }
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

            Section("System") {
                FormCell2 {
                    Text("Total Media Size")
                } right: {
                    Text(LocalMedia.total().description)
                }
                FormCell2 {
                    Text("Total Free Space")
                } right: {
                    Text(File.diskFree().description)
                }

                ConfirmButton(title: "Clean Up Files", action: {
                    LocalMedia.cleanupManual(logout: true)
                }, label: {
                    Text("Clean Up Media")
                })
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
                Button {
                    CoreDataStore.shared.deleteAllRecords(entity: "Con")
                    CoreDataStore.shared.deleteAllRecords(entity: "Contact")
                    CoreDataStore.shared.deleteAllRecords(entity: "GroupInfo")
                    CoreDataStore.shared.deleteAllRecords(entity: "Msg")
                } label: {
                    Text("Reset All Data")
                }

            } header: {

            } footer: {
                Text("Version 1.0.0")
            }
        }
        .navigationTitle("Settings")
    }
}
