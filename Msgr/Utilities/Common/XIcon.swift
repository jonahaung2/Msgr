//
//  XIcon.swift
//  UltimateChords
//
//  Created by Aung Ko Min on 21/3/22.
//

import SwiftUI

struct XIcon: View {
    
    enum Icon: String, CaseIterable {

        case tuningfork, circle, circle_fill, circlebadge, applelogo, pin, pin_fill, plus, plus_circle_fill, message_badge_filled_fill, person_3, person_3_fill, person, person_fill, person_crop_circle, person_2_circle, checkmark_circle_fill

        var systemName: String { self.rawValue.replacingOccurrences(of: "_", with: ".") }
    }
    
    private let icon: Icon
    
    init(_ icon: Icon) {
        self.icon = icon
    }
    
    var body: some View {
        Image(systemName: icon.systemName)
    }
}
