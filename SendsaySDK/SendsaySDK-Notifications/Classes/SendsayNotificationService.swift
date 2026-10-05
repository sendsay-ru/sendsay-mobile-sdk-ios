//
//  SendsayNotificationService.swift
//  SendsaySDKNotifications
//
//  Created by Dominik Hadl on 22/11/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation
import UserNotifications
#if canImport(SendsaySDKShared)
import SendsaySDKShared
#endif

public class SendsayNotificationService {

    private let appGroup: String?
    private let reportAttachmentErrors: Bool
    private var isSDKStopped: Bool {
        UserDefaults(suiteName: appGroup ?? "SendsaySDK")?.value(forKey: "isStopped") as? Bool ?? false
    }

    var request: UNNotificationRequest?
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    var notificationTracked: Bool = false {
        didSet {
            checkDone()
        }
    }
    var contentCreated: Bool = false {
        didSet {
            checkDone()
        }
    }

    /// Creates a service with optional image diagnostics in the push payload.
    /// Enable `reportAttachmentErrors` only for debugging in the example app.
    public init(
        appGroup: String? = nil,
        reportAttachmentErrors: Bool = false
    ) {
        self.appGroup = appGroup
        self.reportAttachmentErrors = reportAttachmentErrors
    }

    public func process(request: UNNotificationRequest, contentHandler: @escaping (UNNotificationContent) -> Void) {
        NSLog("=== SendsayNotificationService: process ===")
        guard Sendsay.isSendsayNotification(userInfo: request.content.userInfo) else {
            Sendsay.logger.log(.verbose, message: "Skipping non-Sendsay notification")
            return
        }
        guard !isSDKStopped else {
            NSLog("=== SendsayNotificationService: STOPPED ===")
            contentHandler(request.content)
            return
        }
        NSLog("=== SendsayNotificationService: TRACKING ===")
        self.request = request
        self.contentHandler = contentHandler

        if let notificationData = prepareNotificationData(request: request),
           let appGroup = appGroup {
            trackDeliveredNotification(appGroup: appGroup, notificationData: notificationData)
            createContent(deliveredTimestamp: notificationData.timestamp)
        }
    }

    public func serviceExtensionTimeWillExpire() {
        // Clean, after we are finished
        defer { clean() }

        // we failed to track notification
        if !notificationTracked {
            if let userInfo = (request?.content.mutableCopy() as? UNMutableNotificationContent)?.userInfo {
            let notification = NotificationData.deserialize(
                attributes: userInfo["attributes"] as? [String: Any] ?? [:],
                campaignData: userInfo["url_params"] as? [String: Any] ?? [:],
                consentCategoryTracking: userInfo["consent_category_tracking"] as? String ?? nil,
                hasTrackingConsent: GdprTracking.readTrackingConsentFlag(userInfo["has_tracking_consent"])
            ) ?? NotificationData()
            saveNotificationForLaterTracking(notification: notification)
            }
        }

        // Try to call content handler with current content
        if let content = bestAttemptContent {
            contentHandler?(content)
        }
    }

    internal func createContent(deliveredTimestamp: Double?) {
        // Create a mutable content and make sure it works
        bestAttemptContent = (request?.content.mutableCopy() as? UNMutableNotificationContent)

        if deliveredTimestamp != nil {
            var additionalInfo = [String: Any]()
            additionalInfo["delivered_timestamp"] = deliveredTimestamp
            bestAttemptContent?.userInfo.merge(additionalInfo) { (_, new) in new }
        }

        if let content = bestAttemptContent {
            bestAttemptContent?.title = content.userInfo["title"] as? String ?? "NO TITLE"
            bestAttemptContent?.body = content.userInfo["message"] as? String ?? ""

            if #available(iOSApplicationExtension 12.0, *) {
                bestAttemptContent?.categoryIdentifier = "SENDSAY_ACTIONABLE"
            }

            // Assign badge if any
            if let badgeString = content.userInfo["badge"] as? String, let badge = Int(badgeString) {
                bestAttemptContent?.badge = badge as NSNumber
            } else {
                bestAttemptContent?.badge = nil
            }

            // Assign sound if any
            if let sound = content.userInfo["sound"] as? String {
                bestAttemptContent?.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: sound))
            }

            // Download and add image, preserving diagnostic errors if enabled.
            attachImage(to: content)

            #warning ("TODO: check image is attaches")
//            guard let imagePath = content.userInfo["image"] as? String,
//            let url = URL(string: imagePath)
//            else {
//                contentCreated = true
//                return
//            }
//            download(url: url) { fileURL in
//                if let fileURL = fileURL,
//                   let attachment = try? UNNotificationAttachment(identifier: "image", url: fileURL, options: nil) {
//                    self.bestAttemptContent?.attachments = [attachment]
//                }
//            }
        }
        contentCreated = true
    }
    
    private func attachImage(to content: UNMutableNotificationContent) {
        guard let imagePath = content.userInfo["image"] as? String else {
            return
        }

        let data: Data
        do {
            guard let url = imagePath.cleanedURL() else {
                throw URLError(.badURL)
            }
            data = try Data(contentsOf: url, options: [])
        } catch {
            recordImageError(error, stage: "download", in: content)
            return
        }

        do {
            let attachment = try saveImage(
                "image.png",
                data: data,
                options: nil
            )
            content.attachments = [attachment]
        } catch {
            recordImageError(error, stage: "attachment", in: content)
        }
    }

    private func recordImageError(
        _ error: Error,
        stage: String,
        in content: UNMutableNotificationContent
    ) {
        let underlyingError = error as NSError
        Sendsay.logger.log(
            .error,
            message: "Push image failed at \(stage): " +
                "\(underlyingError.domain) (\(underlyingError.code))"
        )
        guard reportAttachmentErrors else {
            return
        }

        // Only JSON-compatible values can cross into the application's payload.
        var diagnostics = content.userInfo["_sendsay_debug"]
            as? [String: Any] ?? [:]
        diagnostics["image_error"] = [
            "stage": stage,
            "domain": underlyingError.domain,
            "code": underlyingError.code,
            "message": underlyingError.localizedDescription
        ]
        content.userInfo["_sendsay_debug"] = diagnostics
    }

    private func download(url: URL, completion: @escaping (URL?) -> Void) {
            let task = URLSession.shared.downloadTask(with: url) { tempURL, _, _ in
                guard let tempURL = tempURL else { return completion(nil) }
                let fileExt = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
                let targetURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(fileExt)
                do {
                    try FileManager.default.moveItem(at: tempURL, to: targetURL)
                    completion(targetURL)
                } catch {
                    completion(nil)
                }
            }
            task.resume()
        }

    func trackDeliveredNotification(appGroup: String, notificationData: NotificationData) {
        do {
            let deliveredTracker = try DeliveredNotificationTracker(appGroup: appGroup, notificationData: notificationData)
            deliveredTracker.track(
                onSuccess: {
                    self.notificationTracked = true
                },
                onFailure: {
                    self.saveNotificationEventsForLaterTracking(deliveredTracker.events)
                    self.notificationTracked = true
                }
            )
        } catch {
            Sendsay.logger.log(
                .error,
                message: "Failed to track delivered push notification: \(error.localizedDescription)"
            )
            self.saveNotificationForLaterTracking(notification: notificationData)
            self.notificationTracked = true
        }
    }

    func prepareNotificationData(request: UNNotificationRequest) -> NotificationData? {
        guard let userInfo = (request.content.mutableCopy() as? UNMutableNotificationContent)?.userInfo else {
            Sendsay.logger.log(
                .error,
                message: "Failed to prepare data for delivered push notification:" +
                    " Unable to get user info object from notification."
            )
            self.notificationTracked = true
            return nil
        }

        var notificationData = NotificationData.deserialize(
            attributes: userInfo["attributes"] as? [String: Any] ?? [:],
            campaignData: userInfo["url_params"] as? [String: Any] ?? [:],
            consentCategoryTracking: userInfo["consent_category_tracking"] as? String ?? nil,
            hasTrackingConsent: GdprTracking.readTrackingConsentFlag(userInfo["has_tracking_consent"])
        ) ?? NotificationData()

        let timestamp = notificationData.timestamp
        let sentTimestamp = notificationData.sentTimestamp ?? 0
        let deliveredTimestamp = timestamp <= sentTimestamp ? sentTimestamp + 1 : timestamp

        notificationData.timestamp = deliveredTimestamp
        return notificationData
    }

    func checkDone() {
        if notificationTracked && contentCreated {
            if let content = bestAttemptContent {
                contentHandler?(content)
            }
            clean()
        }
    }

    func saveNotificationForLaterTracking(notification: NotificationData?) {
        guard let appGroup = appGroup,
              let userDefaults = UserDefaults(suiteName: appGroup),
              let notificationData = notification,
              let serialized = notificationData.serialize() else {
            Sendsay.logger.log(.error, message: "Unable to store delivered notification data")
            return
        }
        var delivered = userDefaults.array(forKey: Constants.General.deliveredPushUserDefaultsKey) ?? []
        delivered.append(serialized)
        userDefaults.set(delivered, forKey: Constants.General.deliveredPushUserDefaultsKey)
    }

    func saveNotificationEventsForLaterTracking(_ events: [EventTrackingObject]) {
        guard let appGroup = appGroup,
              let userDefaults = UserDefaults(suiteName: appGroup) else {
            Sendsay.logger.log(.error, message: "Unable to store delivery notification tracking events")
            return
        }
        var deliveredNotifEvents = userDefaults.array(forKey: Constants.General.deliveredPushEventUserDefaultsKey) ?? []
        for each in events {
            guard let trackingData = each.serialize() else {
                Sendsay.logger.log(.error, message: "Unable to store delivery notification tracking event")
                continue
            }
            deliveredNotifEvents.append(trackingData)
        }
        userDefaults.set(deliveredNotifEvents, forKey: Constants.General.deliveredPushEventUserDefaultsKey)
    }

    func saveImage(
        _ identifier: String,
        data: Data,
        options: [AnyHashable: Any]?
    ) throws -> UNNotificationAttachment {
        let temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let directory = temporaryURL.appendingPathComponent(
            ProcessInfo.processInfo.globallyUniqueString,
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: nil
        )
        let fileURL = directory.appendingPathComponent(identifier)
        try data.write(to: fileURL, options: [])
        return try UNNotificationAttachment(
            identifier: identifier,
            url: fileURL,
            options: options
        )
    }

    internal func clean() {
        self.request = nil
        self.contentHandler = nil
        self.bestAttemptContent = nil
    }
}
