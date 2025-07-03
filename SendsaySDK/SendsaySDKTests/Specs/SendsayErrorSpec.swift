//
//  SendsayErrorSpec.swift
//  SendsaySDKTests
//
//  Created by Ricardo Tokashiki on 31/07/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import SendsaySDK

class SendsayErrorSpec: QuickSpec {
    override func spec() {
        describe("A Sendsay error") {

            context("Check for every error level") {

                it("Error not configured") {
                    let sendsayError = SendsayError.notConfigured
                    expect(sendsayError.localizedDescription).to(equal(Constants.ErrorMessages.sdkNotConfigured))
                }

                it("Configured error") {
                    let sendsayError = SendsayError.configurationError("Error Description")
                    let errorDesc = """
                    The provided configuration contains error(s). \
                    Please, fix them before initialising Sendsay SDK.
                    Error Description
                    """
                    expect(sendsayError.localizedDescription).to(equal(errorDesc))
                }

                it("Unknow error") {
                    let sendsayError = SendsayError.unknownError("Unknown")
                    let errorDesc = "Unknown error. Unknown"
                    expect(sendsayError.localizedDescription).to(equal(errorDesc))
                }
            }

        }
    }
}
