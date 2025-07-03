//
//  SendsayAppDelegate.swift
//  SendsaySDK
//
//  Created by Panaxeo on 20/05/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

import Foundation
import UIKit

open class SendsayAppDelegate: NSObject, UNUserNotificationCenterDelegate, UIApplicationDelegate {
    /// When the application is started by opening a push notification we need to get if from launch options.
    /// When you override this method, don't forget to call
    /// super.application(application, didFinishLaunchingWithOptions: launchOptions)
    @discardableResult
    open func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    open func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Sendsay.shared.handlePushNotificationToken(deviceToken: deviceToken)
    }

    open func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Sendsay.shared.handlePushNotificationOpened(userInfo: userInfo)
        completionHandler(.newData)
    }

    open func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Sendsay.shared.handlePushNotificationOpened(response: response)
        completionHandler()
    }

    open func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if IntegrationManager.shared.isStopped && Sendsay.isSendsayNotification(userInfo: notification.request.content.userInfo) {
            Sendsay.logger.log(.error, message: "Will present wont finish, SDK is stopping")
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
            completionHandler([])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}
