//
//  SendsaySDKQuickConfiguration.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 11/03/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

import Quick
@testable import SendsaySDK

class SendsaySDKQuickConfiguration: QuickConfiguration {
    override class func configure(_ configuration: QCKConfiguration) {
        _ = MockUserNotificationCenter.shared
        UNAuthorizationStatusProvider.current = MockUNAuthorizationStatusProviding(status: .authorized)
    }
}
