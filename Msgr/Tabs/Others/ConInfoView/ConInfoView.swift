//
//  ConInfoView.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import SwiftUI
import FirebaseFirestore

struct ConInfoView: View {

    @StateObject private var viewModel: ConInfoViewModel

    init(_ conID: String) {
        _viewModel = .init(wrappedValue: .init(conID))
    }

    var body: some View {
        Form {
            Section {
                Picker("Theme Color", selection: $viewModel.con.themeColor) {
                    ForEach(Con.ThemeColor.allCases) {
                        Image(systemName: "circle.fill")
                            .imageScale(.large)
                            .foregroundColor($0.color)
                            .tag($0)
                    }
                }
                .pickerStyle(.navigationLink)

                Picker("Chat Background", selection: $viewModel.con.bgImage) {
                    ForEach(Con.BgImage.allCases) {
                        Text($0.name)
                            .tag($0)
                    }
                }
                .pickerStyle(.navigationLink)

                Stepper(value: $viewModel.con.cellSpacing, in: 0...10, step: 1) {
                    Text(viewModel.con.cellSpacing.description)
                        .bold()
                        .xBadged("Bubble Spacing")
                }

                Stepper(value: $viewModel.con.bubbleCornorRadius, in: 0...25, step: 1) {
                    Text(viewModel.con.bubbleCornorRadius.description)
                        .bold()
                        .xBadged("Bubble Cornor Radius")
                }
            }

            Section {
                if viewModel.con.isGroup {
                    groupSection()
                } else {
                    oneToOneSection()
                }
            }
        }
        .navigationBarTitle("Conversation Info", displayMode: .inline)
        .onDisappear {
            try? viewModel.con.managedObjectContext?.save()
        }
    }

    @ViewBuilder
    private func oneToOneSection() -> some View {
        if let contactID = viewModel.con.oneToOneID {
            Button {
                TabRouter.shared.currentNavRouter.routes.appendUnique(.contactInfo(contactID))
            } label: {
                Text("Contact Info")
            }
        }
    }

    @ViewBuilder
    private func groupSection() -> some View {
        Button {
            TabRouter.shared.currentNavRouter.routes.appendUnique(.groupInfo(viewModel.con.id))
        } label: {
            Text("Group Info")
        }
    }
}
