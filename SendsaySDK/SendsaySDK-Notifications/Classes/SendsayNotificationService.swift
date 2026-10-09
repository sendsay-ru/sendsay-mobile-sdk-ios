//
//  SendsayNotificationService.swift
//  SendsaySDKNotifications
//
//  Created by Dominik Hadl on 22/11/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation
import ImageIO
import UserNotifications
#if canImport(SendsaySDKShared)
import SendsaySDKShared
#endif

public class SendsayNotificationService {
    /// Root-level keys, in priority order. The first valid HTTP(S) URL wins.
    private static let imageURLKeys = [
        "sendsay_issue_image",
        "image",
        "image-url",
        "image_url",
        "imageUrl"
    ]
    private static let imageDownloadTimeout: TimeInterval = 15
    private static let maximumImageBytes = 10 * 1024 * 1024

    private let appGroup: String?
    private let reportAttachmentErrors: Bool
    private let stateQueue = DispatchQueue(
        label: "com.sendsay.notification-service.state"
    )
    private let stateQueueKey = DispatchSpecificKey<Bool>()
    private var processing: ProcessingState?

    // Keep state changes and delivery completion on one queue. File processing
    // stays on URLSession's callback queue so expiry never waits for image I/O.
    private final class ProcessingState {
        let content: UNMutableNotificationContent
        let contentHandler: (UNNotificationContent) -> Void
        let notificationData: NotificationData
        var notificationTracked = false
        var contentCreated = false
        var isFinished = false
        var downloadTask: URLSessionDownloadTask?
        var downloadSession: URLSession?

        init(
            content: UNMutableNotificationContent,
            contentHandler: @escaping (UNNotificationContent) -> Void,
            notificationData: NotificationData
        ) {
            self.content = content
            self.contentHandler = contentHandler
            self.notificationData = notificationData
        }
    }

    private struct DownloadedImage {
        let attachment: UNNotificationAttachment
        let temporaryURL: URL
    }

    private enum ImageError: LocalizedError {
        case invalidURL
        case invalidResponse
        case httpStatus(Int)
        case missingFile
        case invalidImage
        case imageTooLarge

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "No supported image key contains a valid HTTP(S) URL."
            case .invalidResponse:
                return "The image server did not return an HTTP response."
            case .httpStatus(let status):
                return "The image server returned HTTP \(status)."
            case .missingFile:
                return "The image download did not produce a file."
            case .invalidImage:
                return "The downloaded file is not a recognized image."
            case .imageTooLarge:
                return "The image exceeds the 10 MB attachment limit."
            }
        }
    }

    /// A snapshot for internal consumers; mutable processing state stays private.
    internal var bestAttemptContent: UNMutableNotificationContent? {
        withState {
            processing?.content.mutableCopy() as? UNMutableNotificationContent
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
        stateQueue.setSpecific(key: stateQueueKey, value: true)
    }

    /// Processes a push and invokes its content handler exactly once.
    public func process(
        request: UNNotificationRequest,
        contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        withState {
            Sendsay.logger.log(
                .verbose,
                message: "=== SendsayNotificationService: process ==="
            )
            let userInfo = request.content.userInfo
            let isSDKStopped = UserDefaults(suiteName: appGroup ?? "SendsaySDK")?
                .bool(forKey: "isStopped") ?? false
            guard Sendsay.isSendsayNotification(userInfo: userInfo),
                  !isSDKStopped,
                  let content = request.content.mutableCopy()
                    as? UNMutableNotificationContent else {
                contentHandler(request.content)
                return
            }

            let state = ProcessingState(
                content: content,
                contentHandler: contentHandler,
                notificationData: prepareNotificationData(userInfo: userInfo)
            )
            let previous = processing
            processing = state
            if let previous = previous {
                finishBeforeDeadline(previous)
            }
            guard !state.isFinished else { return }

            configureContent(state)
            if let appGroup = appGroup {
                trackDeliveredNotification(appGroup: appGroup, state: state)
            } else {
                // Image processing does not require an App Group.
                state.notificationTracked = true
            }
            attachImage(state)
        }
    }

    /// Cancels pending image work and submits the best available content.
    public func serviceExtensionTimeWillExpire() {
        withState {
            guard let state = processing else { return }
            finishBeforeDeadline(state)
        }
    }

    private func withState<T>(_ body: () -> T) -> T {
        if DispatchQueue.getSpecific(key: stateQueueKey) == true {
            return body()
        }
        return stateQueue.sync(execute: body)
    }

    private func configureContent(_ state: ProcessingState) {
        let content = state.content
        content.userInfo["delivered_timestamp"] = state.notificationData.timestamp
        // Preserve aps.alert when Sendsay-specific text fields are absent.
        if let title = content.userInfo["title"] as? String {
            content.title = title
        }
        if let message = content.userInfo["message"] as? String {
            content.body = message
        }
        content.categoryIdentifier = "SENDSAY_ACTIONABLE"
        if let badge = content.userInfo["badge"] as? String,
           let value = Int(badge) {
            content.badge = NSNumber(value: value)
        }
        if let sound = content.userInfo["sound"] as? String {
            content.sound = UNNotificationSound(
                named: UNNotificationSoundName(rawValue: sound)
            )
        }
    }

    private func imageURL(in userInfo: [AnyHashable: Any]) throws -> URL? {
        var hasImageField = false
        for key in Self.imageURLKeys {
            guard let value = userInfo[key] else { continue }
            hasImageField = true
            guard let path = value as? String,
                  let url = path.trimmingCharacters(in: .whitespacesAndNewlines)
                    .cleanedURL(),
                  let scheme = url.scheme?.lowercased(),
                  ["https", "http"].contains(scheme),
                  let host = url.host, !host.isEmpty else {
                continue
            }
            return url
        }
        if hasImageField { throw ImageError.invalidURL }
        return nil
    }

    private func attachImage(_ state: ProcessingState) {
        let url: URL
        do {
            guard let imageURL = try imageURL(in: state.content.userInfo) else {
                state.contentCreated = true
                finishIfReady(state)
                return
            }
            url = imageURL
        } catch {
            recordImageError(error, stage: "download", in: state.content)
            state.contentCreated = true
            finishIfReady(state)
            return
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = Self.imageDownloadTimeout
        configuration.timeoutIntervalForResource = Self.imageDownloadTimeout
        let session = URLSession(configuration: configuration)
        state.downloadSession = session
        let task = session.downloadTask(with: url) {
            [weak self] temporaryURL, response, error in
            guard let self = self else { return }
            // Expiry can complete this request while URLSession is calling back.
            guard self.withState({ !state.isFinished }) else { return }

            var stage = "download"
            let result: Swift.Result<DownloadedImage, Error>
            do {
                if let error = error { throw error }
                guard let response = response as? HTTPURLResponse else {
                    throw ImageError.invalidResponse
                }
                guard (200...299).contains(response.statusCode) else {
                    throw ImageError.httpStatus(response.statusCode)
                }
                guard let temporaryURL = temporaryURL else {
                    throw ImageError.missingFile
                }
                stage = "attachment"
                // Move the file before returning from this URLSession callback.
                result = .success(try Self.makeImageAttachment(temporaryURL))
            } catch {
                result = .failure(error)
            }
            let failureStage = stage
            self.stateQueue.async {
                guard !state.isFinished else {
                    if case .success(let image) = result {
                        Self.removeTemporaryFile(image.temporaryURL)
                    }
                    return
                }
                state.downloadTask = nil
                state.downloadSession?.finishTasksAndInvalidate()
                state.downloadSession = nil
                switch result {
                case .success(let image):
                    state.content.attachments = [image.attachment]
                case .failure(let error):
                    self.recordImageError(
                        error,
                        stage: failureStage,
                        in: state.content
                    )
                }
                state.contentCreated = true
                self.finishIfReady(state)
            }
        }
        state.downloadTask = task
        task.resume()
    }

    private static func makeImageAttachment(
        _ temporaryURL: URL
    ) throws -> DownloadedImage {
        let values = try temporaryURL.resourceValues(forKeys: [.fileSizeKey])
        guard let size = values.fileSize, size <= maximumImageBytes else {
            throw ImageError.imageTooLarge
        }
        guard let source = CGImageSourceCreateWithURL(
            temporaryURL as CFURL,
            [kCGImageSourceShouldCache: false] as CFDictionary
        ), CGImageSourceGetCount(source) > 0,
           let type = CGImageSourceGetType(source) else {
            throw ImageError.invalidImage
        }
        // Use the actual file type, independent of the URL's suffix or MIME type.
        let targetURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.moveItem(at: temporaryURL, to: targetURL)
        do {
            let attachment = try UNNotificationAttachment(
                identifier: "push-image",
                url: targetURL,
                options: [
                    UNNotificationAttachmentOptionsTypeHintKey: type as String
                ]
            )
            // Keep successful files available for the notification system.
            return DownloadedImage(
                attachment: attachment,
                temporaryURL: targetURL
            )
        } catch {
            removeTemporaryFile(targetURL)
            throw error
        }
    }

    private static func removeTemporaryFile(_ url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            Sendsay.logger.log(
                .warning,
                message: "Unable to remove unused push image: \(error)"
            )
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
        guard reportAttachmentErrors else { return }
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

    private func trackDeliveredNotification(
        appGroup: String,
        state: ProcessingState
    ) {
        do {
            let tracker = try DeliveredNotificationTracker(
                appGroup: appGroup,
                notificationData: state.notificationData
            )
            tracker.track(
                onSuccess: { [weak self] in
                    self?.stateQueue.async {
                        guard let self = self, !state.isFinished else { return }
                        state.notificationTracked = true
                        self.finishIfReady(state)
                    }
                },
                onFailure: { [weak self] in
                    self?.stateQueue.async {
                        guard let self = self, !state.isFinished else { return }
                        self.saveNotificationEventsForLaterTracking(
                            tracker.events
                        )
                        state.notificationTracked = true
                        self.finishIfReady(state)
                    }
                }
            )
        } catch {
            Sendsay.logger.log(
                .error,
                message: "Failed to track delivered push: \(error)"
            )
            saveNotificationForLaterTracking(
                notification: state.notificationData
            )
            state.notificationTracked = true
        }
    }

    private func prepareNotificationData(
        userInfo: [AnyHashable: Any]
    ) -> NotificationData {
        var data = NotificationData.deserialize(
            attributes: userInfo["attributes"] as? [String: Any] ?? [:],
            campaignData: userInfo["url_params"] as? [String: Any] ?? [:],
            consentCategoryTracking: userInfo["consent_category_tracking"]
                as? String,
            hasTrackingConsent: GdprTracking.readTrackingConsentFlag(
                userInfo["has_tracking_consent"]
            )
        ) ?? NotificationData()
        let sentTimestamp = data.sentTimestamp ?? 0
        if data.timestamp <= sentTimestamp {
            data.timestamp = sentTimestamp + 1
        }
        return data
    }

    private func finishIfReady(_ state: ProcessingState) {
        guard state.notificationTracked, state.contentCreated else { return }
        finish(state)
    }

    private func finishBeforeDeadline(_ state: ProcessingState) {
        guard !state.isFinished else { return }
        if !state.notificationTracked {
            saveNotificationForLaterTracking(
                notification: state.notificationData
            )
        }
        if state.downloadTask != nil {
            recordImageError(
                URLError(.timedOut),
                stage: "download",
                in: state.content
            )
        }
        finish(state)
    }

    private func finish(_ state: ProcessingState) {
        guard !state.isFinished else { return }
        // Mark complete before cancelling: cancellation also invokes callbacks.
        state.isFinished = true
        state.downloadTask?.cancel()
        state.downloadSession?.invalidateAndCancel()
        state.downloadTask = nil
        state.downloadSession = nil
        if processing === state {
            processing = nil
        }
        state.contentHandler(state.content)
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

}
