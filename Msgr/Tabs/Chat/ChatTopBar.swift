//
//  ChatTopBar.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/10/22.
//

import SwiftUI

struct ChatTopBar: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                }

                Spacer()

                Text(viewModel.con.name.str)
                    .bold()
                    .foregroundColor(.primary)
                    .tapToPush(ConInfoView().environmentObject(viewModel))


                Spacer()
                Image(systemName: "star.fill")
                    .tapToPush(ConInfoView().environmentObject(viewModel))
                Button {
                    viewModel.simulateDemoMsg()
                } label: {
                    Image(systemName: "heart.fill")
                        .imageScale(.large)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                }
            }
        }
    }
}

