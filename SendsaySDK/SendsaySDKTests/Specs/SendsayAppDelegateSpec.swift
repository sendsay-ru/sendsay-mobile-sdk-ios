//
//  SendsayAppDelegateSpec.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 27/05/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//
import XCTest
import Quick
import Nimble

@testable import SendsaySDK

final class SendsayAppDelegateSpec: QuickSpec {
    func configureSendsay(requirePushAuthorization: Bool) {
        let sendsay = SendsayInternal()
        Sendsay.shared = sendsay
        Sendsay.shared.configure(
            Sendsay.ProjectSettings(projectToken: "mock-token", authorization: .token("mock-token")),
            pushNotificationTracking: .enabled(
                appGroup: "mock-group",
                delegate: nil,
                requirePushAuthorization: requirePushAuthorization,
                tokenTrackFrequency: .onTokenChange
            )
        )
    }

    override func spec() {
        describe("Push token tracking") {
            context("when push notifications are not authorized") {
                beforeEach {
                    IntegrationManager.shared.isStopped = false
                    UNAuthorizationStatusProvider.current = MockUNAuthorizationStatusProviding(status: .notDetermined)
                }
                it("should not track token if authorization required") {
                    self.configureSendsay(requirePushAuthorization: true)
                    SendsayAppDelegate().application(
                        UIApplication.shared,
                        didRegisterForRemoteNotificationsWithDeviceToken: "mock-token".data(using: .utf8)!
                    )
                    Sendsay.shared.executeSafelyWithDependencies { dependencies in
                        expect(dependencies.trackingManager.customerPushToken).to(beNil())
                    }
                }

                it("should track token if authorization not required") {
                    self.configureSendsay(requirePushAuthorization: false)
                    SendsayAppDelegate().application(
                        UIApplication.shared,
                        didRegisterForRemoteNotificationsWithDeviceToken: "mock-token".data(using: .utf8)!
                    )
                    Sendsay.shared.executeSafelyWithDependencies { dependencies in
                        expect(dependencies.trackingManager.customerPushToken).to(equal("6D6F636B2D746F6B656E"))
                    }
                }
            }

            context("when push notifications are authorized") {
                beforeEach {
                    IntegrationManager.shared.isStopped = false
                    UNAuthorizationStatusProvider.current = MockUNAuthorizationStatusProviding(status: .authorized)
                }
                it("should track token if authorization required") {
                    self.configureSendsay(requirePushAuthorization: true)
                    SendsayAppDelegate().application(
                        UIApplication.shared,
                        didRegisterForRemoteNotificationsWithDeviceToken: "mock-token".data(using: .utf8)!
                    )
                    Sendsay.shared.executeSafelyWithDependencies { dependencies in
                        expect(dependencies.trackingManager.customerPushToken).to(equal("6D6F636B2D746F6B656E"))
                    }
                }

                it("should track token if authorization not required") {
                    self.configureSendsay(requirePushAuthorization: true)
                    SendsayAppDelegate().application(
                        UIApplication.shared,
                        didRegisterForRemoteNotificationsWithDeviceToken: "mock-token".data(using: .utf8)!
                    )
                    Sendsay.shared.executeSafelyWithDependencies { dependencies in
                        expect(dependencies.trackingManager.customerPushToken).to(equal("6D6F636B2D746F6B656E"))
                    }
                }
            }
        }
    }
}
