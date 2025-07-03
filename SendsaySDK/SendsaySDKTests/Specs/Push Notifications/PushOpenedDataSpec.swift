//
//  PushOpenedDataSpec.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 07/09/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//
import Nimble
import Quick

@testable import SendsaySDK

final class PushOpenedDataSpec: QuickSpec {
    override func spec() {
        it("should serialize and deserialize push") {
            let sampleData = PushNotificationsTestData().openedProductionNotificationData
            let serializedString = String(data: sampleData.serialize()!, encoding: String.Encoding.utf8)!
            print(serializedString)
            let deserialized = PushOpenedData.deserialize(from: serializedString.data(using: String.Encoding.utf8)!)
            expect(deserialized).to(equal(sampleData))
        }
    }
}
