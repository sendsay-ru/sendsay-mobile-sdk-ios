//
//  ResultSpec.swift
//  SendsaySDKTests
//
//  Created by Ricardo Tokashiki on 01/08/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import SendsaySDK

class ResultSpec: QuickSpec {
    override func spec() {
        describe("A result") {
            context("Success result value for network requests") {

                let success = Result.success("Success")

                it("Should return a [String: <T>] type") {
                    expect(success.value).to(beAKindOf(String.self))
                }

                it("Should not be nil") {
                    expect(success.value).toNot(beNil())
                }

                it("Should return [Success string]") {
                    expect(success.value).to(equal("Success"))
                }
            }

            context("Error result value for network requests") {

                let error = SendsayError.notConfigured
                let failure = Result<SendsayError>.failure(error)

                it("Should return a [Result<SendsayError>] type") {
                    expect(failure).to(beAKindOf(Result<SendsayError>.self))
                }

                it("Should not return nil") {
                    expect(failure).toNot(beNil())
                }

                it("Failure should be a kind of [Sendsay Error]") {
                    expect(failure.error).to(beAKindOf(SendsayError.self))
                }
            }
        }

        describe("A empty result") {
            context("Success result value for network requests") {

                let success = EmptyResult<RepositoryError>.success

                it("Should not have a [error] value") {
                    expect(success.error).to(beNil())
                }
            }

            context("Error result value for network requests") {

                let error = SendsayError.notConfigured
                let failure = EmptyResult.failure(error)

                it("Should return a [Result<SendsayError>] type") {
                    expect(failure).to(beAKindOf(EmptyResult<SendsayError>.self))
                }

                it("Should not return nil") {
                    expect(failure).toNot(beNil())
                }

                it("Failure should be a kind of [Sendsay Error]") {
                    expect(failure.error).to(beAKindOf(SendsayError.self))
                }
            }
        }

    }
}
