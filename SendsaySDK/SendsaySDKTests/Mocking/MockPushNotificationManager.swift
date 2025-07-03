//
//  MockPushNotificationManager.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 07/11/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

@testable import SendsaySDK

final class MockPushNotificationManager: PushNotificationManagerType {

    var didReceiveSelfPushCheck = false

    weak var delegate: PushNotificationManagerDelegate?

    var handlePushOpenedCalls: [(userInfoObject: AnyObject?, actionIdentifier: String?)] = []
    var handlePushTokenRegisteredCalls: [AnyObject?] = []

    func applicationDidBecomeActive() {
        fatalError("not implemented")
    }

    func handlePushOpened(userInfoObject: AnyObject?, actionIdentifier: String?) {
        handlePushOpenedCalls.append((userInfoObject, actionIdentifier))
    }

    func handlePushTokenRegistered(dataObject: AnyObject?) {
        handlePushTokenRegisteredCalls.append(dataObject)
    }

    func handlePushTokenRegistered(token: String) {
        handlePushTokenRegisteredCalls.append(token as AnyObject)
    }

    func handlePushOpenedWithoutTrackingConsent(userInfoObject: AnyObject?, actionIdentifier: String?) {
        handlePushOpenedCalls.append((userInfoObject, actionIdentifier))
    }

}
