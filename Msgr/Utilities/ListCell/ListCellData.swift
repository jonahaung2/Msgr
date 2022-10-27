//
//  ListCellData.swift
//  TL Device Monitor
//
//  Created by Aung Ko Min on 26/8/22.
//

import SwiftUI

struct ListCellData: Hashable, Identifiable {

    var id: String { title }
    let title: String
    var subTitle: String? = nil
    var icon: XIcon.Icon? = nil
  

    static func == (lhs: ListCellData, rhs: ListCellData) -> Bool {
        return lhs.title == rhs.title && lhs.subTitle == rhs.subTitle
    }
}
