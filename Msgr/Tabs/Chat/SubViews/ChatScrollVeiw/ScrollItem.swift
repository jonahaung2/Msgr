//
//  ScrollItem.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/10/22.
//

import SwiftUI

struct ScrollItem: Equatable {
    let id = UUID()
    let viewId: AnyHashable
    let anchor: UnitPoint
    var animate: Bool = false
}
