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

    private var cancellables = Set<AnyCancellable>()

    init(_con: Con) {
        con = _con
        datasource = .init(conId: _con.id.str)
        datasource
            .$allMsgs
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink {[weak self] value in
                guard let self = self else { return }
                withAnimation {
                    self.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
        NotificationCenter.default
            .publisher(for: .MsgNoti)
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                self.didReceiveNoti(value)
            }
            .store(in: &cancellables)
//        cache
//            .$currentScrolledFrame
//            .debounce(for: 0.2, scheduler: RunLoop.main)
//            .removeDuplicates()
//            .sink { [weak self] value in
//                guard let self = self else { return }
//                self.didUpdateVisibleRect(value)
//            }
//            .store(in: &cancellables)

    }
}

// Receive Updates
extension ChatViewModel {
    private func didReceiveNoti(_ outputt: NotificationCenter.Publisher.Output) {
        guard let noti = outputt.msgNoti else { return }
        switch noti.type {
        case .New(let msg):
            datasource.insert(msg, at: 0, animated: true)
            Audio.playMessageIncoming()
        case .Typing(_):
            break
        case .Update(let id):
            print(id)
        }
    }
}

// Scrolling
extension ChatViewModel {

    func scrollToBottom(_ animated: Bool) {
        scrollItem = ScrollItem(id: 1, anchor: .top, animate: animated)
    }

    func didUpdateVisibleRect(_ visibleRect: CGRect) {
        let scrollButtonShown = visibleRect.minY < 0
        if scrollButtonShown != showScrollToLatestButton {
            withAnimation {
                showScrollToLatestButton = scrollButtonShown
            }
        }
        let nearTop = visibleRect.maxY < UIScreen.main.bounds.height
        if nearTop {
            if self.datasource.loadMoreIfNeeded() {
                self.objectWillChange.send()
            }
        }
    }
}

//
extension ChatViewModel {
    
    func sendMessage() {
        if inputText.isWhitespace {
            withAnimation(.interactiveSpring()) {
                inputText = Lorem.random
            }
            return
        }
        let msg = Msg.create(text: inputText, conId: con.id.str, senderId: CurrentUser.id)
        datasource.insert(msg, at: 0, animated: false)
        inputText.removeAll()
        MsgSender.shard.send(msg_: Msg_(msg: msg))
    }

    func simulatePushNoti() {
        guard let contact_ = con.contact_ else { return }
        let msg_ = Msg_(id: UUID().uuidString, text: Lorem.random, date: Date(), conId: con.id.str, senderId: contact_.id, msgType: Msg.MsgType.Text.rawValue)
        if let token = UserDefaultManager.shared.pushNotificationToken {
            print(token)
            MsgSender.shard.sendIncoming(msg_: msg_, token: token)
        }
    }
    
    func simulateDemoMsg() {
        guard let contact_ = con.contact_ else { return }
        let msg = Msg.create(text: Lorem.random, conId: con.id.str, senderId: contact_.id)
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
