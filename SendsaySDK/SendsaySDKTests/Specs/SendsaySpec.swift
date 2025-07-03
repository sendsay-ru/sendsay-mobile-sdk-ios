//
//  SendsaySpec.swift
//  SendsaySDKTests
//
//  Created by Ricardo Tokashiki on 29/03/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import XCTest
import Quick
import Nimble
import SendsaySDKObjC

@testable import SendsaySDK
@testable import SendsaySDKShared

class SendsaySpec: QuickSpec {

    override func spec() {
        describe("Sendsay SDK") {
            context("Setting automaticSessionTracking after configuration") {
                IntegrationManager.shared.isStopped = false
                let initExpectation = self.expectation(description: "Sendsay automaticSessionTracking init")
                let sendsay = SendsayInternal().onInitSucceeded {
                    initExpectation.fulfill()
                }
                Sendsay.shared = sendsay
                Sendsay.shared.configure(plistName: "SendsayConfig")
                wait(for: [initExpectation], timeout: 10)
                it("should configure automaticSessionTracking correctly") {
                    expect(sendsay.configuration?.automaticSessionTracking).to(equal(true))
                    sendsay.setAutomaticSessionTracking(automaticSessionTracking: Sendsay.AutomaticSessionTracking.disabled)
                    expect(sendsay.configuration?.automaticSessionTracking).to(equal(false))
                    sendsay.setAutomaticSessionTracking(
                        automaticSessionTracking: Sendsay.AutomaticSessionTracking.enabled(timeout: 30.0)
                    )
                    expect(sendsay.configuration?.automaticSessionTracking).to(equal(true))
                    expect(sendsay.configuration?.sessionTimeout).to(equal(30))
                }
            }

            context("Before being configured") {
                var sendsay = SendsayInternal()
                beforeEach {
                    IntegrationManager.shared.isStopped = false
                    sendsay = SendsayInternal()
                }

                it("debug mode combinations") {
                    expect(sendsay.safeModeEnabled).to(beFalse())
                    sendsay.isDebugModeEnabled = true
                    expect(sendsay.safeModeEnabled).to(beFalse())
                    sendsay.isDebugModeEnabled = false
                    expect(sendsay.safeModeEnabled).to(beTrue())
                    sendsay.safeModeEnabled = true
                    expect(sendsay.safeModeEnabled).to(beTrue())
                    sendsay.safeModeEnabled = true
                    sendsay.isDebugModeEnabled = true
                    expect(sendsay.safeModeEnabled).to(beTrue())
                }

                it("Should return a nil configuration") {
                    expect(sendsay.configuration?.projectToken).to(beNil())
                }
                it("Should get flushing mode") {
                    guard case .manual = sendsay.flushingMode else {
                        XCTFail("Expected .manual got \(sendsay.flushingMode)")
                        return
                    }
                }
                it("Should not crash setting flushing mode") {
                    expect(sendsay.flushingMode = .immediate).notTo(raiseException())
                }
                it("Should return empty pushNotificationsDelegate") {
                    expect(sendsay.pushNotificationsDelegate).to(beNil())
                }
                it("Should not crash tracking event") {
                    expect(sendsay.trackEvent(properties: [:], timestamp: nil, eventType: nil)).notTo(raiseException())
                }
                it("Should not crash tracking campaign click") {
                    expect(sendsay.trackCampaignClick(url: URL(sharedSafeString: "mockUrl")!, timestamp: nil))
                        .notTo(raiseException())
                }
                it("Should not crash tracking payment") {
                    expect(sendsay.trackPayment(properties: [:], timestamp: nil)).notTo(raiseException())
                }
                it("Should not crash identifing customer") {
                    expect(sendsay.identifyCustomer(customerIds: [:], properties: [:], timestamp: nil))
                        .notTo(raiseException())
                }
                it("Should not crash tracking push token") {
                    expect(sendsay.trackPushToken("token".data(using: .utf8)!)).notTo(raiseException())
                    expect(sendsay.trackPushToken("token")).notTo(raiseException())
                }
                it("Should not crash tracking push opened") {
                    expect(sendsay.trackPushOpened(with: [:])).notTo(raiseException())
                }
                it("Should not crash tracking session") {
                    expect(sendsay.trackSessionStart()).notTo(raiseException())
                    expect(sendsay.trackSessionEnd()).notTo(raiseException())
                }
                it("Should not crash anonymizing") {
                    expect(sendsay.anonymize()).notTo(raiseException())
                }
            }
            context("After being configured from string") {
                let sendsay = SendsayInternal()
                Sendsay.shared = sendsay
                Sendsay.shared.configure(
                    Sendsay.ProjectSettings(
                        projectToken: "0aef3a96-3804-11e8-b710-141877340e97",
                        authorization: .token("")
                    ),
                    pushNotificationTracking: .disabled
                )
                it("Should return the correct project token") {
                    expect(sendsay.configuration?.projectToken).to(equal("0aef3a96-3804-11e8-b710-141877340e97"))
                }
            }
            context("After being configured from plist file") {
                let initExpectation = self.expectation(description: "Sendsay internal init")
                let sendsay = SendsayInternal().onInitSucceeded {
                    initExpectation.fulfill()
                }
                                
                sendsay.configure(plistName: "SendsayConfig")
                wait(for: [initExpectation], timeout: 10)
                
                it("Should have a project token") {
                    expect(sendsay.configuration?.projectToken).toNot(beNil())
                }
                it("Should return the correct project token") {
                    expect(sendsay.configuration?.projectToken).to(equal("0aef3a96-3804-11e8-b710-141877340e97"))
                }
                it("Should return the default base url") {
                    expect(sendsay.configuration?.baseUrl).to(equal("https://api.sendsay.com"))
                }
                it("Should return the default session timeout") {
                    expect(sendsay.configuration?.sessionTimeout).to(equal(Constants.Session.defaultTimeout))
                }
            }

            context("After being configured from advanced plist file") {
                let sendsay = SendsayInternal()
                Sendsay.shared = sendsay
                Sendsay.shared.configure(plistName: "config_valid")

                it("Should return a custom session timeout") {
                    expect(sendsay.configuration?.sessionTimeout).to(equal(20.0))
                }

                it("Should return automatic session tracking disabled") {
                    expect(sendsay.configuration?.automaticSessionTracking).to(beFalse())
                }

                it("Should return automatic push tracking disabled") {
                    expect(sendsay.configuration?.automaticPushNotificationTracking).to(beFalse())
                }
            }

            context("Setting sendsay properties after configuration") {
                let sendsay = SendsayInternal()
                Sendsay.shared = sendsay
                Sendsay.shared.configure(plistName: "SendsayConfig")

                sendsay.configuration?.projectToken = "NewProjectToken"
                sendsay.configuration?.baseUrl = "NewBaseURL"
                sendsay.configuration?.sessionTimeout = 25.0
                expect(sendsay.configuration?.projectToken).to(equal("NewProjectToken"))
                sendsay.configuration?.automaticSessionTracking = true
                expect(sendsay.configuration?.automaticSessionTracking).to(beTrue())
                expect(sendsay.configuration?.baseUrl).to(equal("NewBaseURL"))
                expect(sendsay.configuration?.sessionTimeout).to(equal(25))
            }

            context("Setting pushNotificationsDelegate") {
                var logger: MockLogger!
                beforeEach {
                    IntegrationManager.shared.isStopped = false
                    logger = MockLogger()
                    Sendsay.logger = logger
                }
                class MockDelegate: PushNotificationManagerDelegate {
                    func pushNotificationOpened(with action: SendsayNotificationActionType,
                                                value: String?, extraData: [AnyHashable: Any]?) {}
                }
                it("Should log warning before Sendsay is configured") {
                    let sendsay = SendsayInternal()
                    let delegate = MockDelegate()
                    sendsay.pushNotificationsDelegate = delegate
                    expect(sendsay.pushNotificationsDelegate).to(beNil())
                    expect(logger.messages.last)
                        .to(match("Cannot set push notifications delegate."))
                }
                it("Should set delegate after Sendsay is configured") {
                    let sendsay = SendsayInternal()
                    sendsay.configure(plistName: "SendsayConfig")
                    let delegate = MockDelegate()
                    // just initialize the notifications manager to clear the swizzling error
                    _ = sendsay.notificationsManager
                    logger.messages.removeAll()
                    sendsay.pushNotificationsDelegate = delegate
                    expect(sendsay.pushNotificationsDelegate).to(be(delegate))
                    expect(logger.messages).to(beEmpty())
                }
            }

            context("executing with dependencies") {
                it("should complete with .success when sendsay is configured") {
                    let sendsay = SendsayInternal()
                    sendsay.configure(plistName: "SendsayConfig")
                    let task: SendsayInternal.DependencyTask<String> = { _, completion in
                        completion(Result.success("success!"))
                    }
                    waitUntil(timeout: .seconds(5)) { done in
                        sendsay.executeSafelyWithDependencies(task) { result in
                            guard case .success(let data) = result else {
                                XCTFail("Result error should be .success")
                                done()
                                return
                            }
                            expect(data).to(equal("success!"))
                            done()
                        }
                    }
                }

                it("should complete with .failure when tasks throws an error") {
                    let sendsay = SendsayInternal()
                    sendsay.configure(plistName: "SendsayConfig")
                    enum MyError: Error {
                        case someError(message: String)
                    }
                    let task: SendsayInternal.DependencyTask<String> = { _, _ in
                        throw MyError.someError(message: "something went wrong")
                    }
                    waitUntil(timeout: .seconds(5)) { done in
                        sendsay.executeSafelyWithDependencies(task) { result in
                            guard case .failure = result else {
                                XCTFail("Result error should be .failure")
                                done()
                                return
                            }
                            guard let error = result.error as? MyError, case .someError = error else {
                                XCTFail("Result error should be .someError")
                                done()
                                return
                            }
                            done()
                        }
                    }
                }

                it("should complete with .failure when tasks raises NSException in safe mode") {
                    let sendsay = SendsayInternal()
                    sendsay.safeModeEnabled = true
                    sendsay.configure(plistName: "SendsayConfig")
                    let task: SendsayInternal.DependencyTask<String> = { _, _ in
                        NSException(
                            name: NSExceptionName(rawValue: "mock exception name"),
                            reason: "mock reason",
                            userInfo: nil
                        ).raise()
                    }
                    waitUntil(timeout: .seconds(5)) { done in
                        sendsay.executeSafelyWithDependencies(task) { result in
                            guard case .failure = result else {
                                XCTFail("Result error should be .failure")
                                done()
                                return
                            }
                            guard let error = result.error as? SendsayError, case .nsExceptionRaised = error else {
                                XCTFail("Result error should be .nsExceptionRaised")
                                done()
                                return
                            }
                            done()
                        }
                    }
                }

                it("should complete any task with .failure after NSException was raised in safe mode") {
                    let sendsay = SendsayInternal()
                    sendsay.safeModeEnabled = true
                    sendsay.configure(plistName: "SendsayConfig")
                    let task: SendsayInternal.DependencyTask<String> = { _, _ in
                        NSException(
                            name: NSExceptionName(rawValue: "mock exception name"),
                            reason: "mock reason",
                            userInfo: nil
                        ).raise()
                    }
                    waitUntil(timeout: .seconds(5)) { done in
                        sendsay.executeSafelyWithDependencies(task) { _ in done() }
                    }
                    let nextTask: SendsayInternal.DependencyTask<String> = { _, completion in
                        completion(Result.success("success!"))
                    }
                    waitUntil(timeout: .seconds(5)) { done in
                        sendsay.executeSafelyWithDependencies(nextTask) { result in
                            guard case .failure = result else {
                                XCTFail("Result should be a failure")
                                done()
                                return
                            }
                            guard let error = result.error as? SendsayError,
                                  case .nsExceptionInconsistency = error else {
                                XCTFail("Result error should be .nsExceptionInconsistency")
                                done()
                                return
                            }
                            done()
                        }
                    }
                }

                it("should re-raise NSException when not in safe mode") {
                    let sendsay = SendsayInternal()
                    sendsay.safeModeEnabled = false
                    sendsay.configure(plistName: "SendsayConfig")
                    let task: SendsayInternal.DependencyTask<String> = { _, _ in
                        NSException(
                            name: NSExceptionName(rawValue: "mock exception name"),
                            reason: "mock reason",
                            userInfo: nil
                        ).raise()
                    }
                    waitUntil(timeout: .seconds(5)) { done in
                        let exception = objc_tryCatch {
                            sendsay.executeSafelyWithDependencies(task) { _ in }
                        }
                        guard exception != nil else {
                            XCTFail("No exception raised")
                            return
                        }
                        expect(exception?.reason).to(equal("mock reason"))
                        done()
                    }
                }
            }

            context("getting customer cookie") {
                it("should return nil before the SDK is configured") {
                    let sendsay = SendsayInternal()
                    expect(sendsay.customerCookie).to(beNil())
                }
                it("should return customer cookie after SDK is configured") {
                    let sendsay = SendsayInternal()
                    sendsay.configure(plistName: "SendsayConfig")
                    expect(sendsay.customerCookie).notTo(beNil())
                }
                it("should return new customer cookie after anonymizing") {
                    let sendsay = SendsayInternal()
                    sendsay.configure(plistName: "SendsayConfig")
                    let cookie1 = sendsay.customerCookie
                    sendsay.anonymize()
                    let cookie2 = sendsay.customerCookie
                    expect(cookie1).notTo(beNil())
                    expect(cookie2).notTo(beNil())
                    expect(cookie1).notTo(equal(cookie2))
                }
            }

            context("anonymizing") {
                func checkEvent(event: TrackEventProxy, eventType: String, projectToken: String, userId: UUID) {
                    expect(event.eventType).to(equal(eventType))
                    expect(event.customerIds["cookie"]).to(equal(userId.uuidString))
                    expect(event.projectToken).to(equal(projectToken))
                }

                func checkCustomer(event: TrackEventProxy, eventType: String, projectToken: String, userId: UUID) {
                    expect(event.eventType).to(equal(eventType))
                    expect(event.customerIds["cookie"]).to(equal(userId.uuidString))
                    expect(event.projectToken).to(equal(projectToken))
                }

                it("should anonymize user and switch projects") {
                    let database = try! DatabaseManager()
                    try! database.clear()

                    let firstCustomer = database.currentCustomer
                    let sendsay = SendsayInternal()
                    Sendsay.shared = sendsay
                    Sendsay.shared.configure(
                        Sendsay.ProjectSettings(projectToken: "mock-token", authorization: .token("mock-token")),
                        pushNotificationTracking: .disabled,
                        flushingSetup: Sendsay.FlushingSetup(mode: .manual)
                    )
                    Sendsay.shared.trackPushToken("token")
                    Sendsay.shared.trackEvent(properties: [:], timestamp: nil, eventType: "test")
                    Sendsay.shared.anonymize(
                        sendsayProject: SendsayProject(
                            projectToken: "other-mock-token",
                            authorization: .token("other-mock-token")
                        ),
                        projectMapping: nil
                    )
                    let secondCustomer = database.currentCustomer

                    let events = try! database.fetchTrackEvent()
                    expect(events.count).to(equal(5))
                    expect(events[0].eventType).to(equal("installation"))
                    expect(events[0].customerIds["cookie"]).to(equal(firstCustomer.uuid.uuidString))
                    expect(events[0].projectToken).to(equal("mock-token"))

                    expect(events[1].eventType).to(equal("test"))
                    expect(events[1].customerIds["cookie"]).to(equal(firstCustomer.uuid.uuidString))
                    expect(events[1].projectToken).to(equal("mock-token"))

                    expect(events[2].eventType).to(equal("session_end"))
                    expect(events[2].customerIds["cookie"]).to(equal(firstCustomer.uuid.uuidString))
                    expect(events[2].projectToken).to(equal("mock-token"))

                    expect(events[3].eventType).to(equal("installation"))
                    expect(events[3].customerIds["cookie"]).to(equal(secondCustomer.uuid.uuidString))
                    expect(events[3].projectToken).to(equal("other-mock-token"))

                    expect(events[4].eventType).to(equal("session_start"))
                    expect(events[4].customerIds["cookie"]).to(equal(secondCustomer.uuid.uuidString))
                    expect(events[4].projectToken).to(equal("other-mock-token"))

                    let customerUpdates = try! database.fetchTrackCustomer()
                    expect(customerUpdates.count).to(equal(3))
                    expect(customerUpdates[0].customerIds["cookie"]).to(equal(firstCustomer.uuid.uuidString))
                    expect(customerUpdates[0].dataTypes)
                        .to(equal([.properties([
                            "apple_push_notification_id": .string("token")
                        ])]))
                    expect(customerUpdates[0].projectToken).to(equal("mock-token"))

                    expect(customerUpdates[1].customerIds["cookie"]).to(equal(firstCustomer.uuid.uuidString))
                    expect(customerUpdates[1].dataTypes)
                        .to(equal([.properties([
                            "apple_push_notification_id": .string("")
                        ])]))
                    expect(customerUpdates[1].projectToken).to(equal("mock-token"))

                    expect(customerUpdates[2].customerIds["cookie"]).to(equal(secondCustomer.uuid.uuidString))
                    expect(customerUpdates[2].dataTypes)
                        .to(equal([.properties([
                            "apple_push_notification_id": .string("token")
                        ])]))
                    expect(customerUpdates[2].projectToken).to(equal("other-mock-token"))
                }

                it("should switch projects with anonymize and store them localy") {
                    let appGroup = "MockAppGroup"
                    let sendsay = SendsayInternal()
                    Sendsay.shared = sendsay
                    Sendsay.shared.configure(
                        Sendsay.ProjectSettings(projectToken: "mock-token", authorization: .token("mock-token")),
                        pushNotificationTracking: .enabled(appGroup: appGroup),
                        flushingSetup: Sendsay.FlushingSetup(mode: .manual)
                    )
                    guard let configuration = Configuration.loadFromUserDefaults(appGroup: appGroup) else {
                        fail("Configuration has not been loaded for \(appGroup)")
                        return
                    }
                    expect(configuration.projectToken).to(equal("mock-token"))
                    expect(configuration.authorization).to(equal(.token("mock-token")))
                    Sendsay.shared.anonymize(
                        sendsayProject: SendsayProject(
                            projectToken: "other-mock-token",
                            authorization: .token("other-mock-token")
                        ),
                        projectMapping: nil
                    )
                    guard let configurationAfterAnonymize = Configuration.loadFromUserDefaults(appGroup: appGroup) else {
                        fail("Configuration has not been loaded after anonymize for \(appGroup)")
                        return
                    }
                    expect(configurationAfterAnonymize.projectToken).to(equal("other-mock-token"))
                    expect(configurationAfterAnonymize.authorization).to(equal(.token("other-mock-token")))
                }
            }
        }
    }
}
