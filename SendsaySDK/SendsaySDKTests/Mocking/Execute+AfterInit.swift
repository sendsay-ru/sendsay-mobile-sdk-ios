//
//  Execute+AfterInit.swift
//  SendsaySDKTests
//
//  Created by Ankmara on 07.02.2023.
//  Copyright © 2023 Sendsay. All rights reserved.
//

import XCTest
import Quick
import Nimble
import SendsaySDKObjC

@testable import SendsaySDK
@testable import SendsaySDKShared

class SendsaySpecInitSpec: QuickSpec {

    private var counter: Int = 0
    private let sdkInstance = MockSendsayImplementation()

    func failMethod() throws {
        throw NSError(domain: "error", code: 0)
    }

    func successMethod() {
        counter += 1
    }

    func successTryMethod() throws {
        let name = "test"
        if name != "test" {
            throw NSError(domain: "error", code: 99)
        } else {
            counter += 1
        }
    }

    override func spec() {
        context("executing after sendsay init") {
            let manager = self.sdkInstance.afterInit
            it("After init manager") {
                /// Counter += 1
                manager.doActionAfterSendsayInit(self.increment)
                expect(manager.actionBlocks.count).to(equal(1))
                /// Counter += 1
                self.sdkInstance.executeSafely(self.increment)
                expect(manager.actionBlocks.count).to(equal(2))
                waitUntil(timeout: .seconds(10)) { done in
                    expect {
                        manager.doActionAfterSendsayInit {
                            expect {
                                try self.failMethod()
                            }.to(throwError())
                        }
                    }.toNot(throwError())
                    expect(manager.actionBlocks.count).to(equal(3))
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                        /// Counter += 1
                        manager.doActionAfterSendsayInit(self.increment)
                        expect(manager.actionBlocks.count).to(equal(4))
                        done()
                    }
                }
                self.sdkInstance.executeSafely(self.increment)
                expect(manager.actionBlocks.count).to(equal(5))
                self.sdkInstance.configure(plistName: "SendsayConfig")
                expect(manager.actionBlocks.isEmpty).to(beTruthy())
                expect(self.counter).to(equal(4))
                /// Counter += 1
                manager.doActionAfterSendsayInit(self.increment)
                expect(manager.actionBlocks.isEmpty).to(beTruthy())
                expect {
                    /// Counter += 1
                    try manager.doActionAfterSendsayInit(self.successTryMethod)
                    expect(manager.actionBlocks.isEmpty).to(beTruthy())
                }.toNot(throwError())
                expect(self.counter).to(equal(6))
                waitUntil(timeout: .seconds(10)) { done in
                    expect {
                        try manager.doActionAfterSendsayInit {
                            try self.failMethod()
                        }
                    }.to(throwError())
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                        /// Counter += 1
                        manager.doActionAfterSendsayInit(self.increment)
                        expect(manager.actionBlocks.isEmpty).to(beTruthy())
                        done()
                    }
                }
                expect(self.counter).to(equal(7))
                /// Just clean
                self.clean()
                expect(self.counter).to(equal(0))
                waitUntil(timeout: .seconds(10)) { done in
                    self.sdkInstance.executeSafely {
                        try self.failMethod()
                    } errorHandler: { error in
                        expect((error as NSError).domain).to(equal("error"))
                        self.increment()
                        done()
                    }
                }
                expect(self.counter).to(equal(1))
            }
        }
    }

    @discardableResult
    func clean() -> Int {
        counter = 0
        let manager = self.sdkInstance.afterInit
        manager.clean()
        return manager.actionBlocks.count
    }

    func increment() {
        counter += 1
    }
}
