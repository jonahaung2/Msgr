//
//  ChatViewManager.swift
//  Msgr
//
//  Created by Aung Ko Min on 21/10/22.
//

import SwiftUI
import Combine

final class ChatViewModel: ObservableObject {

    var selectedMsg: Msg?
    var quotedMsg: Msg?
    var markedMsgDisplayInfo: MsgDisplayInfo?
    var scrollItem: ScrollItem = .init(viewId: 1, anchor: .top)
    var showScrollToLatestButton = false

    let datasource: ChatDatasource
    let conversation: Conversation
    private let chatViewUpdates = ChatViewUpdates()

    private var isFirstLoad = true
    private var cancellables = Set<AnyCancellable>()

    init(_ conID: String) {
        conversation = .init(conID)
        datasource = .init(conID)
        chatViewUpdates
            .$blockOperations
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink { [weak self] value in
                guard let self else { return }
                if value.count > 0 {
                    self.chatViewUpdates.handleUpdates()
                } else {
                    self.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
        datasource
            .objectWillChange
            .debounce(for: 0.1, scheduler: RunLoop.main)
            .sink { [weak self] value in
                guard let self else { return }
                self.queueForUpdate()
            }
            .store(in: &cancellables)
        conversation
            .objectWillChange
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { [weak self] value in
                guard let self else { return }
                self.queueForUpdate()
            }
            .store(in: &cancellables)
    }

    func task() {
        guard isFirstLoad else {
            objectWillChange.send()
            return
        }
        isFirstLoad = false
        conversation.startObserving()
        try? conversation.updateIncomingHasRead()
    }

    deinit {
        Log("ChatViewModel")
    }
}

// Actions
extension ChatViewModel {

    func setMarkedMsg(_ info: MsgDisplayInfo?) {
        HapticsEngine.shared.playTick()
        markedMsgDisplayInfo = info
        queueForUpdate()
    }

    func setSelectedMsg(_ msg: Msg?) {
        HapticsEngine.shared.playTick()
        selectedMsg = selectedMsg == msg ? nil : msg
        queueForUpdate()
    }
    func setQuoteddMsg(_ msg: Msg?) {
        HapticsEngine.shared.playTick()
        quotedMsg = msg
        queueForUpdate()
    }
}

// Update
extension ChatViewModel {
    func queueForUpdate(block: (@escaping () -> Void) = {}) {
        chatViewUpdates.insert(block)
    }
}
// Scrolling
extension ChatViewModel {
    
    func scrollToBottom(_ animated: Bool) {
        scrollItem = ScrollItem(viewId: 1, anchor: .top, animate: animated)
        queueForUpdate()
    }

    func didUpdateVisibleRect(_ visibleRect: CGRect) {
        let scrollButtonShown = visibleRect.minY < 0
        if scrollButtonShown != showScrollToLatestButton {
            showScrollToLatestButton = scrollButtonShown
            if !scrollButtonShown {
                datasource.reset { [weak self] in
                    guard let self else { return }
                    self.queueForUpdate()
                }
            } else {
                queueForUpdate()
            }
        } else {
            if showScrollToLatestButton {
                let screenHeight = UIScreen.main.bounds.height
                let nearTop = visibleRect.maxY - screenHeight < 0
                if nearTop {
                    datasource.loadMoreIfNeeded { [weak self] in
                        guard let self else { return }
                        self.objectWillChange.send()
                    }
                }
            }
        }
    }
}


extension ChatViewModel {
    
    private func canShowTimeSeparater(_ date: Date, _ previousDate: Date) -> Bool {
        abs(date.getDifference(from: previousDate, unit: .second)) > 60
    }

    func msgStyle(prev: Msg?, msg: Msg, next: Msg?) -> MsgStyle {
        var cornors: UIRectCorner = []
        var showAvatar = false
        var showTimeSeparater = false
        var showTopPadding = false

        let isSelected = msg.id == selectedMsg?.id
        let nextIsSelected = next?.id == selectedMsg?.id
        let prevIsSelected = prev?.id == selectedMsg?.id

        let isSender = msg.isSender

        if isSender {
            cornors.formUnion(.topLeft)
            cornors.formUnion(.bottomLeft)
            if let prev {
                showTimeSeparater = self.canShowTimeSeparater(msg.date, prev.date)
                showTopPadding = !showTimeSeparater && msg.senderId != prev.senderId
                if (showTimeSeparater || showTopPadding || msg.msgType != prev.msgType || isSelected || prevIsSelected ) {
                    cornors.formUnion(.topRight)
                }
            } else {
                cornors.formUnion(.topRight)

            }
            if let next {
                if
                    msg.senderId != next.senderId ||
                     msg.msgType != next.msgType ||
                     isSelected ||
                     nextIsSelected ||
                     canShowTimeSeparater(msg.date, next.date) {

                    cornors.formUnion(.bottomRight)
                }
            }else {
                cornors.formUnion(.bottomRight)
            }
        } else {
            cornors.formUnion(.topRight)
            cornors.formUnion(.bottomRight)
            if let prev {
                showTimeSeparater = canShowTimeSeparater(msg.date, prev.date)
                showTopPadding = !showTimeSeparater && msg.senderId != prev.senderId

                if showTopPadding || showTimeSeparater || msg.msgType != prev.msgType || isSelected || prevIsSelected {
                    cornors.formUnion(.topLeft)
                }
            } else {
                cornors.formUnion(.topLeft)
            }

            if let next {
                if msg.senderId != next.senderId || msg.msgType != next.msgType || isSelected || nextIsSelected || canShowTimeSeparater(msg.date, next.date) {

                    cornors.formUnion(.bottomLeft)
                }
            } else {
                cornors.formUnion(.bottomLeft)
            }
            showAvatar = cornors.contains(.bottomLeft)
        }

        let bubbleShape = BubbleShape(corners: cornors, cornorRadius: conversation.con.bubbleCornorRadius.cgFloat)
        let textColor = isSender ? ChatKit.textTextColorOutgoing : nil
        let bubbleColor = conversation.con.bubbleColor(for: msg)

        let reducted = false

        return MsgStyle(bubbleShape: bubbleShape, showAvatar: showAvatar, showTimeSeparater: showTimeSeparater, showTopPadding: showTopPadding, isSelected: isSelected, bubbleColor: bubbleColor, textColor: textColor, isSender: isSender, reducted: reducted)
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
