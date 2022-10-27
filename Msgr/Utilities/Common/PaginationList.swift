//
//  PaginationList.swift
//  Device Monitor
//
//  Created by Aung Ko Min on 8/9/22.
//

import SwiftUI

struct PaginationList<Content: View, Item: Identifiable>: View {

  @Binding var items: [Item]
  let content: (Item) -> Content

  @State private var isLoading: Bool = false
  @State private var page: Int = 0
  private let pageSize: Int = 25
  private let offset: Int = 10

  private var displayItems: [Item] { Array(items.prefix(((page * pageSize) + pageSize) - 1))}

  var body: some View {
    Group {
      ForEach(displayItems) { item in
        content(item)
      }
      VStack {
        Text("Loading More")
          .foregroundStyle(.tertiary)
          .onAppear {
            guard !isLoading else { return }
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
              page += 1
              isLoading = false
            }
          }
      }
    }
  }
}

private extension PaginationList {
  func listItemAppears<Item: Identifiable>(_ item: Item) {
    if displayItems.isThresholdItem(
      offset: offset,
      item: item
    ) {
      isLoading = true
      /*
       Simulated async behaviour:
       Creates items for the next page and
       appends them to the list after a short delay
       */
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
        page += 1
        isLoading = false
        //                let moreItems = getMoreItems(forPage: page, pageSize: pageSize)
        //                items.append(contentsOf: moreItems)
        //                isLoading = false
      }
    }
  }
}


extension RandomAccessCollection where Self.Element: Identifiable {
  public func isLastItem<Item: Identifiable>(_ item: Item) -> Bool {
    guard !isEmpty else {
      return false
    }

    guard let itemIndex = lastIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
      return false
    }

    let distance = self.distance(from: itemIndex, to: endIndex)
    return distance == 1
  }

  public func isThresholdItem<Item: Identifiable>(
    offset: Int,
    item: Item
  ) -> Bool {
    guard !isEmpty else {
      return false
    }

    guard let itemIndex = lastIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
      return false
    }

    let distance = self.distance(from: itemIndex, to: endIndex)
    let offset = offset < count ? offset : count - 1
    return offset == (distance - 1)
  }
}
