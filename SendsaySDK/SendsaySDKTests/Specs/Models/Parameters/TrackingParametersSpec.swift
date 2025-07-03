//
//  TrackingParametersSpec.swift
//  SendsaySDKTests
//
//  Created by Ricardo Tokashiki on 31/07/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import SendsaySDKShared

class TrackingParametersSpec: QuickSpec {
    override func spec() {
        describe("A tracking parameter") {
            context("Setting group of parameters to track") {

                let mockData = MockData()

                let param = TrackingParameters(
                    customerIds: mockData.customerIds,
                    properties: mockData.properties,
                    timestamp: nil,
                    eventType: nil)

                it("Should return a [String: JSONValue] type") {
                    expect(param.parameters).to(beAKindOf([String: JSONValue].self))
                }

                it("Should not return nil") {
                    expect(param.parameters).toNot(beNil())
                }
                it("should contains required properties") {
                    if let propertiesReqDic = param.requestParameters["properties"] as? [String: Any],
                       let propertiesDic = propertiesReqDic["properties"] as? [String: Any],
                       let platform = propertiesDic["platform"] as? String {
                        expect(platform).to(equal("ios"))
                    } else {
                        fail("properties missing")
                    }
                }
            }
        }
    }
}
