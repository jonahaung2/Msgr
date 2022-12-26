//
//  ListCellData.swift
//  TL Device Monitor
//
//  Created by Aung Ko Min on 26/8/22.
//

import Foundation

struct ListCellData: Hashable, Identifiable {
    let id = UUID().uuidString
    let title: String
    let subTitle: String?
    let icon: XIcon.Icon?
}
