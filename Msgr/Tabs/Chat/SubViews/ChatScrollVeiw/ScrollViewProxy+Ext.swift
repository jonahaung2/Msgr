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
                scrollTo(item.viewId, anchor: item.anchor)
            }
        } else {
            scrollTo(item.viewId, anchor: item.anchor)
        }
    }
}
