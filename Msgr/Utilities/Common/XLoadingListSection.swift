//
//  XProgressView.swift
//  Device Monitor
//
//  Created by Aung Ko Min on 4/9/22.
//

import SwiftUI

struct XLoadingListSection: View {
    var show: Bool
    var body: some View {
        Group {
            if show {
                Section {
//                    ForEach(transactions) { _ in
//                        HStack { Text("Year Month Day"); Text("Style"); Spacer(); Text("123") }
//                    }
                }
                .redacted(reason: .placeholder)
            }
        }
    }
}
