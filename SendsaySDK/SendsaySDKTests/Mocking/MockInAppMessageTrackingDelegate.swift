//
//  MockInAppMessageTrackingDelegate.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 16/12/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

@testable import SendsaySDK

class MockInAppMessageTrackingDelegate: InAppMessageTrackingDelegate {

    struct CallData: Equatable {
        let event: InAppMessageEvent
        let message: InAppMessage
    }
    public var calls: [CallData] = []

    public func track(_ event: SendsaySDK.InAppMessageEvent, for message: SendsaySDK.InAppMessage, trackingAllowed: Bool, isUserInteraction: Bool) {
        calls.append(CallData(event: event, message: message))
    }
}
