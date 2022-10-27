//
//  ConInfoView.swift
//  Msgr
//
//  Created by Aung Ko Min on 27/10/22.
//

import SwiftUI

struct ConInfoView: View {

    @EnvironmentObject private var viewModel: ChatViewModel
    
    var body: some View {
        Form {
            Picker("Theme Color", selection: $viewModel.con.themeColor) {
                ForEach(Con.ThemeColor.allCases) {
                    Text($0.name)
                        .tag($0)
                }
            }
            .pickerStyle(.menu)

            Picker("Background", selection: $viewModel.con.bgImage) {
                ForEach(Con.BgImage.allCases) {
                    Text($0.name)
                        .tag($0)
                }
            }
            .pickerStyle(.menu)

            Stepper(value: $viewModel.con.cellSpacing, in: 0...10, step: 1) {
                HStack {
                    Text("Cell Spacing")
                    Text(viewModel.con.cellSpacing.description)
                        .bold()
                }
            }

            Stepper(value: $viewModel.con.bubbleCornorRadius, in: 0...25, step: 1) {
                HStack {
                    Text("Bubble Radius")
                    Text(viewModel.con.bubbleCornorRadius.description)
                        .bold()
                }
            }
        }
        .onDisappear {
            Persistence.shared.save()
        }
        .navigationTitle(viewModel.con.name.str)
    }
}
