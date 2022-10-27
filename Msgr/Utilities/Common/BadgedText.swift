//
//  BadgedText.swift
//  Device Monitor
//
//  Created by Aung Ko Min on 23/9/22.
//

import SwiftUI

struct BadgedText: View {
   let string: String
   let badge: String

    var body: some View {
       HStack(alignment: .bottom) {
          Text(string)
          Text(badge)
             .font(.footnote)
             .foregroundStyle(.secondary)
       }
    }
}

