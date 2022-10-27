//
//  XPicker.swift
//  Device Monitor
//
//  Created by Aung Ko Min on 21/9/22.
//

import SwiftUI

public protocol XPickable {
   var title: String { get }
}

public struct XPickerView<Item: XPickable>: View {
   public let items: [Item]
   @Binding public var pickedItem: Item
   @State private var searchText = ""
   private var currentItems: [Item] {
      searchText.isWhitespace ? items : items.filter{ $0.title.lowercased().contains(searchText.lowercased())}
   }
   @Environment(\.dismiss) var dismiss

   public var body: some View {
      List(currentItems, id: \.title) { item in
         Button {
            pickedItem = item
            DispatchQueue.main.async {
               dismiss()
            }
         } label: {
            HStack {
               Text(item.title)
                  .foregroundColor(.primary)
               Spacer()
               if item.title == pickedItem.title {
                  Image(systemName: "checkmark")
               }
            }
         }
         .buttonStyle(.borderless)
      }
      .navigationTitle("Pick an item")
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
   }
}

public struct XPicker<Item: XPickable>: View {
   public let title: String
   public let items: [Item]
   @Binding public  var pickedItem: Item

   public var body: some View {
      HStack {
         Text(title)
         Spacer()
         Text(pickedItem.title)
            .foregroundStyle(Color.accentColor)
      }
      .tapToPush(XPickerView(items: items, pickedItem: $pickedItem))
   }
}
