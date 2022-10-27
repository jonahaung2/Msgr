//
//  ChatViewManager.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI
import Combine

final class ChatViewModel: ObservableObject {

    @Published var con: Con
    @Published var scrollItem: ScrollItem?
    @Published var inputText = ""
    @Published var selectedId: String?
    @Published var showScrollToLatestButton = false
   
    let datasource: ChatDatasource
    let cache = MessageCachingUtils.shared

    private var cancellables = Set<AnyCancellable>()
    init(_con: Con) {
        con = _con
        datasource = .init(conId: _con.id.str)
        datasource
            .$msgs
            .sink {[weak self] value in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}

// Scrolling
extension ChatViewModel {
    func scrollToBottom(_ animated: Bool) {
        scrollItem = ScrollItem(id: 1, anchor: .top, animate: animated)
    }
}

//
extension ChatViewModel {
    func sendMessage() {
        if inputText.isWhitespace {
            withAnimation(.interactiveSpring()) {
                inputText = Lorem.sentence
            }
            return
        }
        let msg = Msg.create(text: inputText, conId: con.id.str, senderId: "aung", recipeantType: .Send)
        inputText.removeAll()
        datasource.insert(msg, at: 0, animated: true)
    }
    
    func simulateDemoMsg() {
        let msg = Msg.create(text: Lorem.sentence, conId: con.id.str, senderId: "ko", recipeantType: .Receive)
        datasource.insert(msg, at: 0, animated: true)
    }
}

extension ChatViewModel {
    
    private func prevMsg(for msg: Msg, at i: Int, from msgs: [Msg]) -> Msg? {
        guard i < msgs.count-1 else { return nil }
        return msgs[i + 1]
    }

    private func nextMsg(for msg: Msg, at i: Int, from msgs: [Msg]) -> Msg? {
        guard i > 0 else { return nil }
        return msgs[i - 1]
    }

    private func canShowTimeSeparater(_ date: Date, _ previousDate: Date) -> Bool {
        date.getDifference(from: previousDate, unit: .second) > 30
    }

    func msgStyle(for this: Msg, at index: Int, selectedId: String?) -> MsgStyle {
        let msgs = datasource.msgs
        let thisIsSelectedId = this.id == selectedId
        let isSender = this.recieptType == .Send

        var rectCornors: UIRectCorner = []
        var showAvatar = false
        var showTimeSeparater = false
        var showTopPadding = false

        if isSender {

            rectCornors.formUnion(.topLeft)
            rectCornors.formUnion(.bottomLeft)

            if let lhs = prevMsg(for: this, at: index, from: msgs) {

                showTimeSeparater = self.canShowTimeSeparater(lhs.date!, this.date!)

                if
                    (this.recieptType != lhs.recieptType ||
                     this.msgType != lhs.msgType ||
                     thisIsSelectedId ||
                     lhs.id == selectedId ||
                     showTimeSeparater) {

                    rectCornors.formUnion(.topRight)

                    showTopPadding = !showTimeSeparater && this.recieptType != lhs.recieptType
                }
            } else {
                rectCornors.formUnion(.topRight)
            }

            if let rhs = nextMsg(for: this, at: index, from: msgs) {

                if
                    (this.recieptType != rhs.recieptType ||
                     this.msgType != rhs.msgType ||
                     thisIsSelectedId ||
                     rhs.id == selectedId ||
                     self.canShowTimeSeparater(this.date!, rhs.date!)) {
                    rectCornors.formUnion(.bottomRight)
                }
            }else {
                rectCornors.formUnion(.bottomRight)
            }
            showAvatar = this.id == con.lastReadMsgId
        } else {

            rectCornors.formUnion(.topRight)
            rectCornors.formUnion(.bottomRight)

            if let lhs = prevMsg(for: this, at: index, from: msgs) {
                showTimeSeparater = self.canShowTimeSeparater(this.date!, lhs.date!)

                if
                    (this.recieptType != lhs.recieptType ||
                     this.msgType != lhs.msgType ||
                     thisIsSelectedId ||
                     lhs.id == selectedId ||
                     showTimeSeparater) {

                    rectCornors.formUnion(.topLeft)

                    showTopPadding = !showTimeSeparater && this.recieptType != lhs.recieptType
                }
            } else {
                rectCornors.formUnion(.topLeft)
            }

            if let rhs = nextMsg(for: this, at: index, from: msgs) {
                if
                    (this.recieptType != rhs.recieptType ||
                     this.msgType != rhs.msgType ||
                     thisIsSelectedId ||
                     rhs.id == selectedId ||
                     self.canShowTimeSeparater(rhs.date!, this.date!)) {
                    rectCornors.formUnion(.bottomLeft)
//                    showAvatar = con.showAvatar
                    showAvatar = true
                }
            }else {
                rectCornors.formUnion(.bottomLeft)
            }
        }

        let bubbleShape = this.msgType == .Text ? BubbleShape(corners: rectCornors, cornorRadius: con.bubbleCornorRadius.cgFloat) : nil

        return MsgStyle(bubbleShape: bubbleShape, showAvatar: showAvatar, showTimeSeparater: showTimeSeparater, showTopPadding: showTopPadding, isSelected: thisIsSelectedId)
    }
}
