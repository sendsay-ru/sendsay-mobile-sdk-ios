//
//  Sendsay+ConfigurationSpec.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 22/11/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

import Quick
import Nimble

@testable import SendsaySDK

class SendsayConfigurationSpec: QuickSpec, PushNotificationManagerDelegate {
    func pushNotificationOpened(
        with action: SendsayNotificationActionType,
        value: String?,
        extraData: [AnyHashable: Any]?
    ) {}

    override func spec() {
        describe("Creating configuration") {
            it("should setup simplest configuration") {
                let sendsay = SendsayInternal()
                sendsay.configure(
                    Sendsay.ProjectSettings(
                        projectToken: "mock-project-token",
                        authorization: .none
                    ),
                    pushNotificationTracking: .disabled
                )
                guard let configuration = sendsay.configuration else {
                    XCTFail("Nil configuration")
                    return
                }
                expect(configuration.projectMapping).to(beNil())
                expect(configuration.projectToken).to(equal("mock-project-token"))
                expect(configuration.baseUrl).to(equal(Constants.Repository.baseUrl))
                expect(configuration.defaultProperties).to(beNil())
                expect(configuration.sessionTimeout).to(equal(Constants.Session.defaultTimeout))
                expect(configuration.automaticSessionTracking).to(equal(true))
                expect(configuration.automaticPushNotificationTracking).to(equal(false))
                expect(configuration.tokenTrackFrequency).to(equal(.onTokenChange))
                expect(configuration.appGroup).to(beNil())
                expect(configuration.flushEventMaxRetries).to(equal(Constants.Session.maxRetries))
                guard case .immediate = sendsay.flushingMode else {
                    XCTFail("Incorect flushing mode")
                    return
                }
                expect(sendsay.pushNotificationsDelegate).to(beNil())
            }

            it("should setup complex configuration") {
                let sendsay = SendsayInternal()
                sendsay.configure(
                    Sendsay.ProjectSettings(
                        projectToken: "mock-project-token",
                        authorization: .none,
                        baseUrl: "mock-url",
                        projectMapping: [
                            .payment: [
                                SendsayProject(
                                    baseUrl: "other-mock-url",
                                    projectToken: "other-project-id",
                                    authorization: .token("some-token")
                                )
                            ]
                        ]
                    ),
                    pushNotificationTracking: .enabled(
                        appGroup: "mock-app-group",
                        delegate: self,
                        requirePushAuthorization: false,
                        tokenTrackFrequency: .onTokenChange
                    ),
                    automaticSessionTracking: .enabled(timeout: 12345),
                    defaultProperties: ["mock-prop-1": "mock-value-1", "mock-prop-2": 123],
                    flushingSetup: Sendsay.FlushingSetup(mode: .periodic(111), maxRetries: 123),
                    advancedAuthEnabled: false
                )
                guard let configuration = sendsay.configuration else {
                    XCTFail("Nil configuration")
                    return
                }
                expect(configuration.projectMapping).to(
                    equal([.payment: [
                        SendsayProject(
                            baseUrl: "other-mock-url",
                            projectToken: "other-project-id",
                            authorization: .token("some-token")
                        )
                    ]])
                )
                expect(configuration.projectToken).to(equal("mock-project-token"))
                expect(configuration.baseUrl).to(equal("mock-url"))
                expect(configuration.defaultProperties).notTo(beNil())
                expect(configuration.defaultProperties?["mock-prop-1"] as? String).to(equal("mock-value-1"))
                expect(configuration.defaultProperties?["mock-prop-2"] as? Int).to(equal(123))
                expect(configuration.sessionTimeout).to(equal(12345))
                expect(configuration.automaticSessionTracking).to(equal(true))
                expect(configuration.automaticPushNotificationTracking).to(equal(false))
                expect(configuration.requirePushAuthorization).to(equal(false))
                expect(configuration.tokenTrackFrequency).to(equal(.onTokenChange))
                expect(configuration.appGroup).to(equal("mock-app-group"))
                expect(configuration.flushEventMaxRetries).to(equal(123))
                expect(configuration.advancedAuthEnabled).to(equal(false))
                guard case .periodic(let period) = sendsay.flushingMode else {
                    XCTFail("Incorect flushing mode")
                    return
                }
                expect(period).to(equal(111))
                expect(sendsay.pushNotificationsDelegate).notTo(beNil())
            }

            it("should allow single initialisation") {
                for run in 0..<200 {
                    Sendsay.logger.logLevel = .verbose
                    var sdkInitMessageCount = 0
                    Sendsay.logger.addLogHook { message in
                        if message.contains("SDK init starts synchronously") {
                            sdkInitMessageCount += 1
                        }
                    }
                    let sendsay = SendsayInternal()
                    var initsCount = 0
                    let maxInitsCount = 50
                    var tokenWinner = ""
                    let group = DispatchGroup()
                    waitUntil(timeout: .seconds(10)) { done in
                        for i in 0..<maxInitsCount {
                            DispatchQueue.global(qos: .background).async(group: group) {
                                sendsay.configure(
                                    Sendsay.ProjectSettings(
                                        projectToken: "mock-project-token-\(i)",
                                        authorization: .none
                                    ),
                                    pushNotificationTracking: .disabled
                                )
                                if let conf = sendsay.configuration,
                                   conf.projectToken == "mock-project-token-\(i)",
                                   tokenWinner == "" {
                                    tokenWinner = conf.projectToken
                                }
                                initsCount += 1
                                if initsCount == maxInitsCount {
                                    done()
                                }
                            }
                        }
                    }
                    expect(sendsay.configuration!.projectToken).to(equal(tokenWinner))
                    expect(sdkInitMessageCount).to(equal(1))
                    if sdkInitMessageCount != 1 {
                        break
                    }
                    if let conf = sendsay.configuration {
                        expect(conf.projectToken).to(equal(tokenWinner))
                        expect(sendsay.configuration!.projectToken).to(equal(tokenWinner))
                        expect(sdkInitMessageCount).to(equal(1))
                        if sdkInitMessageCount != 1 {
                            break
                        }
                        if let conf = sendsay.configuration {
                            expect(conf.projectToken).to(equal(tokenWinner))
                        }
                    }
                }
            }
        }
    }
}
