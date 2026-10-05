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
    private var pendingAlerts: [AlertMessage] = []
    private var isPresentingAlert = false

    private struct AlertMessage {
        let title: String
        let message: String
    }

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

    func applicationDidBecomeActive(_ application: UIApplication) {
        presentNextAlert()
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
        enqueueAlerts([
            AlertMessage(title: title, message: message ?? "no body")
        ])
    }

    private func enqueueAlerts(_ alerts: [AlertMessage]) {
        onMain {
            self.pendingAlerts.append(contentsOf: alerts)
            self.presentNextAlert()
        }
    }

    private func presentNextAlert() {
        guard !isPresentingAlert else {
            return
        }
        guard !pendingAlerts.isEmpty else {
            if let alertWindow = alertWindow {
                let wasKeyWindow = alertWindow.isKeyWindow
                alertWindow.isHidden = true
                self.alertWindow = nil
                if wasKeyWindow {
                    window?.makeKeyAndVisible()
                }
            }
            return
        }
        // Defer alerts received during launch or background delivery.
        guard UIApplication.shared.applicationState == .active else {
            return
        }

        if alertWindow == nil {
            let newWindow: UIWindow
            if let scene = window?.windowScene {
                newWindow = UIWindow(windowScene: scene)
            } else {
                newWindow = UIWindow(frame: UIScreen.main.bounds)
            }
            newWindow.rootViewController = UIViewController()
            newWindow.windowLevel = .alert + 1
            alertWindow = newWindow
        }
        guard let presenter = alertWindow?.rootViewController else {
            return
        }

        let next = pendingAlerts.removeFirst()
        let alert = UIAlertController(
            title: next.title,
            message: next.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "ОК",
            style: .default,
            handler: { [weak self, weak alert] _ in
                guard let self = self, let alert = alert else {
                    return
                }
                // Present the next item only after dismissal has completed.
                alert.dismiss(animated: true) { [weak self] in
                    self?.isPresentingAlert = false
                    self?.presentNextAlert()
                }
            }
        ))
        isPresentingAlert = true
        alertWindow?.makeKeyAndVisible()
        presenter.present(alert, animated: true)
    }
}

extension AppDelegate: PushNotificationManagerDelegate {
    func pushNotificationOpened(
        with action: SendsayNotificationActionType,
        value: String?,
        extraData: [AnyHashable: Any]?
    ) {
        showPushPayload("Push attributes", payload: extraData)
    }

    func pushNotificationOpened(
        with action: SendsayNotificationActionType,
        value: String?,
        extraData: [AnyHashable: Any]?,
        payload: [AnyHashable: Any]?
    ) {
        showPushPayload("Push notification opened", payload: payload)
    }

    func silentPushNotificationReceived(extraData: [AnyHashable: Any]?) {
        showPushPayload("Silent push attributes", payload: extraData)
    }

    func silentPushNotificationReceived(
        extraData: [AnyHashable: Any]?,
        payload: [AnyHashable: Any]?
    ) {
        showPushPayload("Silent push received", payload: payload)
    }

    private func showPushPayload(
        _ title: String,
        payload: [AnyHashable: Any]?
    ) {
        var alerts: [AlertMessage] = []
        var displayPayload = payload
        if let diagnostics = payload?["_sendsay_debug"] as? [String: Any],
           let imageError = diagnostics["image_error"] as? [String: Any] {
            let stage = imageError["stage"] as? String ?? "unknown"
            let domain = imageError["domain"] as? String ?? "unknown"
            let code = (imageError["code"] as? NSNumber)?.stringValue ?? "—"
            let description = imageError["message"] as? String
                ?? "Описание ошибки отсутствует."
            alerts.append(AlertMessage(
                title: "Ошибка изображения в пуше",
                message: "Этап: \(stage)\nДомен: \(domain)\n" +
                    "Код: \(code)\n\n\(description)"
            ))
            // Strip diagnostics only from the copy shown to the user.
            displayPayload?.removeValue(forKey: "_sendsay_debug")
        }

        let message: String
        if let displayPayload = displayPayload {
            do {
                message = try PushPayloadFormatter.string(from: displayPayload)
            } catch {
                Sendsay.logger.log(
                    .error,
                    message: "Push payload JSON formatting failed: \(error)"
                )
                message = "Unable to format push payload as JSON."
            }
        } else {
            message = "Push payload is unavailable."
        }
        Sendsay.logger.log(.verbose, message: "\(title): \(message)")
        alerts.append(AlertMessage(title: title, message: message))
        // Enqueue the pair together so other pushes cannot separate the alerts.
        enqueueAlerts(alerts)
    }
}

/// Formats the complete payload without changing its JSON value types.
private enum PushPayloadFormatter {
    enum FormattingError: Error {
        case invalidJSONObject
    }

    static func string(from payload: [AnyHashable: Any]) throws -> String {
        guard JSONSerialization.isValidJSONObject(payload) else {
            throw FormattingError.invalidJSONObject
        }
        let data = try JSONSerialization.data(
            withJSONObject: payload,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        return String(decoding: data, as: UTF8.self)
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
