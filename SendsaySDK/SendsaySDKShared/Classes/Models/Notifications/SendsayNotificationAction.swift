//
//  SendsayNotificationAction.swift
//  SendsaySDKShared
//
//  Created by Dominik Hadl on 19/12/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation
import UserNotifications

public struct SendsayNotificationAction: Codable {
    public let title: String
    public let action: SendsayNotificationActionType
    public let url: String?

    public var isTrackingForced: Bool {
        GdprTracking.isTrackForced(url)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        action = try container.decode(SendsayNotificationActionType.self, forKey: .action)
        url = try container.decodeIfPresent(String.self, forKey: .url)
    }

    public static func createNotificationAction(type: SendsayNotificationActionType,
                                                title: String, index: Int) -> UNNotificationAction {
        return UNNotificationAction(
            identifier: type.identifier + "_" + String(index),
            title: title,
            options: [.foreground]
        )
    }
}
