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
    @Published var isTyping = false
   
    let datasource: ChatDatasource
    let cache = MessageCachingUtils.shared
    private let pushNotificationSender = PushNotificationSender.shared

    private var cancellables = Set<AnyCancellable>()
    init(_con: Con) {
        con = _con
        datasource = .init(conId: _con.id.str)
        datasource
            .$allMsgs
            .removeDuplicates()
            .sink {[weak self] value in
                guard let self = self else { return }
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        cache
            .$scrollOffset
            .removeDuplicates()
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink {[weak self] value in
                guard let self = self else { return }
                let scrollButtonShown = value < -20
                if scrollButtonShown != self.showScrollToLatestButton {
                    withAnimation {
                        self.showScrollToLatestButton = scrollButtonShown

                    }
                }

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
        
        let msg = Msg.create(text: inputText, conId: con.id.str, senderId: CurrentUser.shared.user.id.str)
        DispatchQueue.performSynchronouslyOnMainQueue {
            datasource.insert(msg, at: 0, animated: true)
            self.inputText.removeAll()
        }
    }
    func simulatePushNoti() {
        if let msg = datasource.msgs.first {
            pushNotificationSender.sendPushNotification(to: UserDefaultManager.shared.pushNotificationToken, msg: msg)
        }
    }
    
    func simulateDemoMsg() {
        guard let contact = con.contact else { return }
        let msg = Msg.create(text: Lorem.sentence, conId: con.id.str, senderId: contact.id.str)
        msg.deliveryStatus = .Received
        DispatchQueue.performSynchronouslyOnMainQueue {
            self.datasource.insert(msg, at: 0, animated: true)
        }

    }
    func simulateHasRead() {
        guard let last = datasource.msgs.first, let date = last.date else { return }
        datasource.msgs.filter{ $0.deliveryStatus.rawValue < Msg.DeliveryStatus.Sent.rawValue && $0.date ?? Date() <= date }.forEach { msg in
            if msg.recieptType == .Send {
                msg.deliveryStatus = .Sent
            }
        }
    }
}

extension ChatViewModel {
    
    private func prevMsg(for msg: Msg, at i: Int, from msgs: ArraySlice<Msg>) -> Msg? {
        guard i < msgs.count-1 else { return nil }
        return msgs[i + 1]
    }

    private func nextMsg(for msg: Msg, at i: Int, from msgs: ArraySlice<Msg>) -> Msg? {
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

        let previousMsg = prevMsg(for: this, at: index, from: msgs)
        let nextMsg = nextMsg(for: this, at: index, from: msgs)

        if isSender {
            rectCornors.formUnion(.topLeft)
            rectCornors.formUnion(.bottomLeft)

            if let previousMsg {
                showTimeSeparater = self.canShowTimeSeparater(previousMsg.date!, this.date!)

                if
                    (this.recieptType != previousMsg.recieptType ||
                     this.msgType != previousMsg.msgType ||
                     thisIsSelectedId ||
                     previousMsg.id == selectedId ||
                     showTimeSeparater) {

                    rectCornors.formUnion(.topRight)

                    showTopPadding = !showTimeSeparater && this.recieptType != previousMsg.recieptType
                }
            } else {
                rectCornors.formUnion(.topRight)
            }

            if let nextMsg {
                showTimeSeparater = self.canShowTimeSeparater(this.date!, nextMsg.date!)

                if
                    (this.recieptType != nextMsg.recieptType ||
                     this.msgType != nextMsg.msgType ||
                     thisIsSelectedId ||
                     nextMsg.id == selectedId ||
                     showTimeSeparater) {
                    rectCornors.formUnion(.bottomRight)
                }
            }else {
                rectCornors.formUnion(.bottomRight)
            }
        } else {
            rectCornors.formUnion(.topRight)
            rectCornors.formUnion(.bottomRight)

            if let previousMsg = prevMsg(for: this, at: index, from: msgs) {
                showTimeSeparater = self.canShowTimeSeparater(this.date!, previousMsg.date!)

                if
                    (this.recieptType != previousMsg.recieptType ||
                     this.msgType != previousMsg.msgType ||
                     thisIsSelectedId ||
                     previousMsg.id == selectedId ||
                     showTimeSeparater) {

                    rectCornors.formUnion(.topLeft)

                    showTopPadding = !showTimeSeparater && this.recieptType != previousMsg.recieptType

                }
            } else {
                rectCornors.formUnion(.topLeft)
            }

            if let nextMsg {
                if
                    (this.recieptType != nextMsg.recieptType ||
                     this.msgType != nextMsg.msgType ||
                     thisIsSelectedId ||
                     nextMsg.id == selectedId ||
                     self.canShowTimeSeparater(nextMsg.date!, this.date!)) {
                    rectCornors.formUnion(.bottomLeft)
                    showAvatar = true
                }
            }else {
                rectCornors.formUnion(.bottomLeft)
                showAvatar = true
            }
        }

        let bubbleShape = BubbleShape(corners: rectCornors, cornorRadius: con.bubbleCornorRadius.cgFloat)
        let textColor = this.recieptType == .Send ? ChatKit.textTextColorOutgoing : nil
        
        return MsgStyle(bubbleShape: bubbleShape, showAvatar: showAvatar, showTimeSeparater: showTimeSeparater, showTopPadding: showTopPadding, isSelected: thisIsSelectedId, bubbleColor: con.bubbleColor(for: this), textColor: textColor)
    }
}
