//
//  PushNotificationParser.swift
//  SendsaySDK
//
//  Created by Panaxeo on 23/10/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

import Foundation
import UserNotifications
#if canImport(SendsaySDKShared)
import SendsaySDKShared
#endif

struct PushNotificationParser {
    static let decoder: JSONDecoder = JSONDecoder.snakeCase

    static func parsePushOpened(userInfoObject: AnyObject?,
                                actionIdentifier: String?,
                                timestamp: Double,
                                considerConsent: Bool
    ) -> PushOpenedData? {
        guard let userInfo = userInfoObject as? [String: Any] else {
            Sendsay.logger.log(.error, message: "Failed to convert push payload.")
            return nil
        }

        let silent = userInfo["silent"] as? Int == 1
        var eventData: [DataType] = []
        var eventType = silent ? EventType.pushDelivered : EventType.pushOpened
        var properties: [String: JSONValue] = [
            "status": .string(silent ? "delivered" : "clicked"),
            "cta": .string("notification"),
            "url": .string("app")
        ]
        if let consentCategoryTracking = userInfo["consent_category_tracking"] as? String {
            properties["consent_category_tracking"] = .string(consentCategoryTracking)
        }
        let notificationData = NotificationData.deserialize(
            attributes: userInfo["attributes"] as? [String: Any] ?? [:],
            campaignData: userInfo["url_params"] as? [String: Any] ?? [:],
            consentCategoryTracking: userInfo["consent_category_tracking"] as? String ?? nil,
            hasTrackingConsent: GdprTracking.readTrackingConsentFlag(userInfo["has_tracking_consent"]),
            considerConsent: considerConsent
        ) ?? NotificationData()
        properties.merge(notificationData.properties) { (current, _) in current }
        if let customEventType = notificationData.eventType,
           !customEventType.isEmpty,
           customEventType != Constants.EventTypes.pushOpen {
            eventType = .customEvent
            eventData.append(.eventType(customEventType))
        }

        #warning ("TODO: local save attributes")
        // 14014 handle
        if let userDefaults = UserDefaults(suiteName: Constants.Tracking.sendsayPushNotificationExtraData) {
            if let issue = notificationData.attributes[Constants.Keys.issueId] {
                userDefaults.set(issue.rawValue, forKey: Constants.Tracking.issueIdKey)
            }
            if let letter = notificationData.attributes[Constants.Keys.letterId] {
                userDefaults.set(letter.rawValue, forKey: Constants.Tracking.letterIdKey)
            }
        } else {
            Sendsay.logger.log(.error, message: "Unable to store local attributes")
        }
//        if let userDefaults = UserDefaults(suiteName: Constants.Tracking.sendsayPushNotificationExtraData) {
//            /// attributes is extraData in our case:
//            userDefaults.set(notificationData.attributes[Constants.Keys.issueId], forKey: Constants.Tracking.issueIdKey)
//            userDefaults.set(notificationData.attributes[Constants.Keys.letterId], forKey: Constants.Tracking.letterIdKey)
//        } else {
//            Sendsay.logger.log(.error, message: "Unable to store local attributes")
//        }
        
//            let delivered = userDefaults.array(forKey: Constants.General.deliveredPushUserDefaultsKey) ?? []
//            delivered.append(serialized)
//            userDefaults.set(delivered, forKey: Constants.General.deliveredPushUserDefaultsKey)
        

        // Handle actions

        let action: SendsayNotificationActionType
        let actionValue: String?

        // If we have action identifier then a button was pressed
        if let identifier = actionIdentifier, identifier != UNNotificationDefaultActionIdentifier {
            // Fetch action (only a value if a custom button was pressed)
            // Format of action id should look like - SENDSAY_APP_OPEN_ACTION_0
            // We need to get the right index and fetch the correct action url from payload, if any
            let indexString = identifier.components(separatedBy: "_").last
            if let indexString = indexString, let index = Int(indexString),
               let actions = userInfo["actions"] as? [[String: String]],
               actions.count > index {
                let actionDict = actions[index]
                action = SendsayNotificationActionType(rawValue: actionDict["action"] ?? "") ?? .none
                actionValue = actionDict["url"]

                // Track the notification action title
                if let name = actionDict["title"] {
                    properties["cta"] = .string(name)
                }

            } else {
                action = .none
                actionValue = nil
            }
        } else {
            // Fetch notification action (on tap of notification)
            let notificationActionString = (userInfo["action"] as? String ?? "")
            action = SendsayNotificationActionType(rawValue: notificationActionString) ?? .none
            actionValue = userInfo["url"] as? String
        }

        switch action {
        case .none, .openApp, .selfCheck:
            break

        case .browser, .deeplink:
            if let value = actionValue, value.cleanedURL() != nil {
                properties["url"] = .string(value)
                if (GdprTracking.isTrackForced(value)) {
                    properties["tracking_forced"] = .bool(true)
                }
            }
        }

        eventData.append(.properties(properties))
        let currentTimestamp = timestamp
        let deliveredTimestamp = userInfo["delivered_timestamp"] as? Double ?? 0
        let openedTimestamp = currentTimestamp <= deliveredTimestamp ? deliveredTimestamp + 1 : currentTimestamp
        eventData.append(.timestamp(openedTimestamp))

        return PushOpenedData(
            silent: silent,
            campaignData: notificationData.campaignData,
            actionType: action,
            actionValue: actionValue,
            eventType: eventType,
            eventData: eventData,
            extraData: userInfo["attributes"] as? [String: Any],
            consentCategoryTracking: notificationData.consentCategoryTracking,
            hasTrackingConsent: notificationData.hasTrackingConsent,
            considerConsent: notificationData.considerConsent,
            origin: userInfo
        )
    }
}
