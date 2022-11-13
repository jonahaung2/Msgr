//
//  MockServer.swift
//  Msgr
//
//  Created by Aung Ko Min on 29/10/22.
//


import Foundation
import CoreData
protocol DownloadTask {
    func cancel()
    var isCancelled: Bool { get }
}
class MockServer: ObservableObject {

    var con: Con?
    private let queue = DispatchQueue(label: "MockServerQueue")

    @discardableResult
    func fetchEntries(since startDate: Date, completion: @escaping (Result<[Msg.Payload], Error>) -> Void) -> DownloadTask {
        let entries = generateFakeEntries(from: con!)
        return MockDownloadTask(delay: Double.random(in: 0..<2.5), queue: queue, onSuccess: {
            completion(.success(entries))
        }, onCancelled: {
            completion(.failure(DownloadError.cancelled))
        })
    }


    private func generateFakeEntries(from con: Con) -> [Msg.Payload] {
        if let contact_ = con.contactPayload {
            let msg_ = Msg.Payload(id: UUID().uuidString, text: Lorem.paragraph, date: Date(), conId: con.id.str, senderId: contact_.id, msgType: Msg.MsgType.Text.rawValue)
            return [msg_]
        }
        return []
    }
}


extension MockServer {

    enum DownloadError: Error {
        case cancelled
    }

    private class MockDownloadTask: DownloadTask {

        var isCancelled = false
        let onCancelled: () -> Void
        let queue: DispatchQueue

        init(delay: TimeInterval, queue: DispatchQueue, onSuccess: @escaping () -> Void, onCancelled: @escaping () -> Void) {
            self.onCancelled = onCancelled
            self.queue = queue
            queue.asyncAfter(deadline: .now() + delay) {
                if !self.isCancelled {
                    onSuccess()
                }
            }
        }

        func cancel() {
            queue.async {
                guard !self.isCancelled else { return }
                self.isCancelled = true
                self.onCancelled()
            }
        }
    }
}
