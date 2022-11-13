//
//  ScrollViewProxy+Ext.swift
//  Msgr
//
//  Created by Aung Ko Min on 22/10/22.
//

import SwiftUI

extension ScrollViewProxy {
    func scroll(to item: ScrollItem) {
        if item.animate {
            withAnimation {
                scrollTo(item.id, anchor: item.anchor)
            }
        } else {
            scrollTo(item.id, anchor: item.anchor)
        }
    }
}
