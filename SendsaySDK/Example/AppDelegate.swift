//
//  AppDelegate.swift
//  Example
//
//  Created by Dominik Hadl on 01/05/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import UIKit
import SendsaySDK
import UserNotifications
import IQKeyboardManagerSwift
import Firebase
//import FirebaseMessaging

// This protocol is used queried using reflection by native iOS SDK to see if SDK is used by our example app
@objc(IsSendsayExampleApp)
protocol IsSendsayExampleApp {
}

@UIApplicationMain
class AppDelegate: SendsayAppDelegate {

    static let memoryLogger = MemoryLogger()
    var window: UIWindow?
    var alertWindow: UIWindow?
    let discoverySegmentsCallback = SegmentCallbackData(
        category: .discovery(),
        isIncludeFirstLoad: false
    ) { newSegments in
        notifyNewSegments(categoryName: "discovery", segments: newSegments)
    }
    let contentSegmentsCallback = SegmentCallbackData(
        category: .content(),
        isIncludeFirstLoad: false
    ) { newSegments in
        notifyNewSegments(categoryName: "content", segments: newSegments)
    }
    let merchandisingSegmentsCallback = SegmentCallbackData(
        category: .merchandising(),
        isIncludeFirstLoad: false
    ) { newSegments in
        notifyNewSegments(categoryName: "merchandising", segments: newSegments)
    }

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        super.application(application, didFinishLaunchingWithOptions: launchOptions)
        Sendsay.logger = AppDelegate.memoryLogger
        Sendsay.logger.logLevel = .verbose
        SegmentationManager.shared.addCallback(callbackData: discoverySegmentsCallback)
        SegmentationManager.shared.addCallback(callbackData: contentSegmentsCallback)
        SegmentationManager.shared.addCallback(callbackData: merchandisingSegmentsCallback)
        
        DispatchQueue.main.async {
            IQKeyboardManager.shared.isEnabled = true
            IQKeyboardManager.shared.resignOnTouchOutside = true
            //        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        }

        FirebaseApp.configure()
//        Messaging.messaging().delegate = self

        UITabBar.appearance().tintColor = .darkText
        UINavigationBar.appearance().backgroundColor = UIColor.colorAccent
        UIBarButtonItem.appearance().tintColor = UIColor.colorPrimary
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.colorPrimaryDark
        ]
        UINavigationBar.appearance().inputViewController?.tabBarController?.moreNavigationController
            .navigationBar.topItem?.rightBarButtonItem?.title = ""
        UINavigationBar.appearance().inputViewController?.tabBarController?.moreNavigationController
            .navigationBar.topItem?.rightBarButtonItem?.isEnabled = false

        application.applicationIconBadgeNumber = 0

        // Set legacy sendsay categories
        let category1 = UNNotificationCategory(identifier: "EXAMPLE_LEGACY_CATEGORY_1",
                                              actions: [
            SendsayNotificationAction.createNotificationAction(type: .openApp, title: "Hardcoded open app", index: 0),
            SendsayNotificationAction.createNotificationAction(type: .deeplink, title: "Hardcoded deeplink", index: 1)
            ], intentIdentifiers: [], options: [])

        let category2 = UNNotificationCategory(identifier: "EXAMPLE_LEGACY_CATEGORY_2",
                                               actions: [
            SendsayNotificationAction.createNotificationAction(type: .browser, title: "Hardcoded browser", index: 0)
            ], intentIdentifiers: [], options: [])
        
        

        UNUserNotificationCenter.current().setNotificationCategories([category1, category2])
        
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()

        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL
            else { return false }
        Sendsay.shared.trackCampaignClick(url: incomingURL, timestamp: nil)
        if let type = DeeplinkType(input: incomingURL.absoluteString) {
            DeeplinkManager.manager.setDeeplinkType(type: type)
        }
        return incomingURL.host == "old.panaxeo.com"
    }

    func application(
           _ app: UIApplication,
           open url: URL,
           options: [UIApplication.OpenURLOptionsKey: Any] = [:]
       ) -> Bool {
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false), components.scheme == "sendsay" {
            if let type = DeeplinkType(input: url.absoluteString) {
                DeeplinkManager.manager.setDeeplinkType(type: type)
            } else {
                onMain(self.showAlert("Deeplink received", url.absoluteString))
            }
            return true
        }
        return false
    }

    private static func notifyNewSegments(categoryName: String, segments: [SegmentDTO]) {
        Sendsay.logger.log(
            .verbose,
            message: "Segments: New for category \(categoryName) with IDs: [" + segments.map {
                return "{ segmentation_id=\($0.segmentationId), id=\($0.id) }"
            }.joined() + "]"
        )
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            super.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
        }
}

extension AppDelegate {
    func showAlert(_ title: String, _ message: String?) {
        let alert = UIAlertController(title: title, message: message ?? "no body", preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: "Ok",
                style: .default,
                handler: { [weak self] _ in self?.alertWindow?.isHidden = true }
            )
        )
        if alertWindow == nil {
            alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow?.rootViewController = UIViewController()
            alertWindow?.windowLevel = .alert + 1
        }
        alertWindow?.makeKeyAndVisible()
        alertWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

extension AppDelegate: PushNotificationManagerDelegate {
    func pushNotificationOpened(
        with action: SendsayNotificationActionType,
        value: String?,
        extraData: [AnyHashable: Any]?
    ) {
        Sendsay.logger.log(
            .verbose,
            message: "Alert push opened, " +
                "action \(action), value: \(String(describing: value)), extraData \(String(describing: extraData))"
        )
        onMain(self.showAlert(
            "Push notification opened",
            "action \(action), value: \(String(describing: value)), extraData \(String(describing: extraData))"
        ))
    }

    func silentPushNotificationReceived(extraData: [AnyHashable: Any]?) {
        Sendsay.logger.log(
            .verbose,
            message: "Silent push received, extraData \(String(describing: extraData))"
        )
        onMain {
            self.showAlert(
                "Silent push received",
                "extraData \(String(describing: extraData))"
            )
        }
    }
}

//extension AppDelegate: MessagingDelegate {
//  // [START refresh_token]
//  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//    print("Firebase registration token: \(String(describing: fcmToken))")
//
//    let dataDict: [String: String] = ["token": fcmToken ?? ""]
//    NotificationCenter.default.post(
//      name: Notification.Name("FCMToken"),
//      object: nil,
//      userInfo: dataDict
//    )
//    // TODO: If necessary send token to application server.
//    // Note: This callback is fired at each app startup and whenever a new token is generated.
//  }
//
//  // [END refresh_token]
//}

class InAppDelegate: InAppMessageActionDelegate {
    let overrideDefaultBehavior: Bool
    let trackActions: Bool

    init(
        overrideDefaultBehavior: Bool,
        trackActions: Bool
    ) {
        self.overrideDefaultBehavior = overrideDefaultBehavior
        self.trackActions = trackActions
    }

    func inAppMessageClickAction(message: SendsaySDK.InAppMessage, button: SendsaySDK.InAppMessageButton) {
        Sendsay.logger.log(
            .verbose,
            message: "In app action performed, messageId: \(message.id), button: \(String(describing: button))"
        )
        (UIApplication.shared.delegate as? AppDelegate)?.showAlert(
            "In app action performed",
            "messageId: \(message.id), button: \(String(describing: button))"
        )
        Sendsay.shared.trackInAppMessageClick(message: message, buttonText: button.text, buttonLink: button.url)
    }

    func inAppMessageCloseAction(message: SendsaySDK.InAppMessage, button: SendsaySDK.InAppMessageButton?, interaction: Bool) {
        Sendsay.logger.log(
            .verbose,
            message: "In app action performed, messageId: \(message.id),"
            + " interaction: \(interaction), button: \(String(describing: button))"
        )
        (UIApplication.shared.delegate as? AppDelegate)?.showAlert(
            "In app action performed",
            "messageId: \(message.id), interaction: \(interaction), button: \(String(describing: button))"
        )
        Sendsay.shared.trackInAppMessageClose(message: message, buttonText: button?.text, isUserInteraction: false)
    }

    func inAppMessageShown(message: SendsaySDK.InAppMessage) {
        Sendsay.logger.log(.verbose, message: "In app message \(message.name) has been shown")
    }

    func inAppMessageError(message: SendsaySDK.InAppMessage?, errorMessage: String) {
        Sendsay.logger.log(
            .verbose,
            message: "Error occurred '\(errorMessage)' while showing in app message \(message?.name ?? "<no_name>")"
        )
    }
}
