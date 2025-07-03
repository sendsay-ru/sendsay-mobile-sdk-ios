//
//  MockInAppMessagesCache.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 05/12/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

@testable import SendsaySDK

final class MockInAppMessagesCache: InAppMessagesCacheType {
    private var messages: [InAppMessage] = []
    private var images: [String: Data] = [:]
    private var timestamp: TimeInterval = 0
    private var saveImageDataCallCounter = 0

    func saveInAppMessages(inAppMessages: [InAppMessage]) {
        self.messages = inAppMessages
    }

    func getInAppMessages() -> [InAppMessage] {
        return messages
    }

    func getInAppMessagesTimestamp() -> TimeInterval {
        return timestamp
    }

    func setInAppMessagesTimestamp(_ timestamp: TimeInterval) {
        self.timestamp = timestamp
    }

    func deleteImages(except: [String]) {
        images = images.filter { except.contains($0.key) }
    }

    func hasImageData(at imageUrl: String) -> Bool {
        return images.contains { $0.key == imageUrl }
    }

    func saveImageData(at imageUrl: String, data: Data) {
        images[imageUrl] = data
        saveImageDataCallCounter += 1
    }

    func getImageData(at imageUrl: String) -> Data? {
        return images[imageUrl]
    }

    func clear() {
        images = [:]
        messages = []
    }

    func getImageDownloadCount() -> Int {
        return saveImageDataCallCounter
    }
}
