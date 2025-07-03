//
//  MockLogger.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 04/09/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

import Foundation

@testable import SendsaySDK

class MockLogger: Logger {
    @Atomic public var messages: [String] = []
    override open func logMessage(_ message: String) {
        super.logMessage(message)
        _messages.changeValue(with: { $0.append(message) })
    }
}
