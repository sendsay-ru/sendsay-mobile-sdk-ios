//
//  ConfigItem.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 18.07.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

public struct ConfigItem: Codable, Equatable, CustomStringConvertible {

    public let isInAppMessagesEnabled: Bool
    public let isInAppCBEnabled: Bool
    public let isAppInboxEnabled: Bool
    public let isADTrackEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case isInAppMessagesEnabled = "isInAppMessagesEnabled"
        case isInAppCBEnabled = "isInAppCBEnabled"
        case isAppInboxEnabled = "isAppInboxEnabled"
        case isADTrackEnabled = "isADTrackEnabled"
    }
    
    public var description: String { return "ConfigItem: isInAppMessagesEnabled:\(isInAppMessagesEnabled), isInAppCBEnabled:\(isInAppCBEnabled), isAppInboxEnabled:\(isAppInboxEnabled), isADTrackEnabled:\(isADTrackEnabled)" }

    public init(
        isInAppMessagesEnabled: Bool,
        isInAppCBEnabled: Bool,
        isAppInboxEnabled: Bool,
        isADTrackEnabled: Bool
    ) {
        self.isInAppMessagesEnabled = isInAppMessagesEnabled
        self.isInAppCBEnabled = isInAppCBEnabled
        self.isAppInboxEnabled = isAppInboxEnabled
        self.isADTrackEnabled = isADTrackEnabled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isInAppMessagesEnabled = try? container.decode(Bool.self, forKey: .isInAppMessagesEnabled)
        let isInAppCBEnabled = try? container.decode(Bool.self, forKey: .isInAppCBEnabled)
        let isAppInboxEnabled = try? container.decode(Bool.self, forKey: .isAppInboxEnabled)
        let isADTrackEnabled = try? container.decode(Bool.self, forKey: .isADTrackEnabled)
        self.init(
            isInAppMessagesEnabled: isInAppMessagesEnabled ?? false,
            isInAppCBEnabled: isInAppCBEnabled ?? false,
            isAppInboxEnabled: isAppInboxEnabled ?? false,
            isADTrackEnabled: isADTrackEnabled ?? false
        )
    }
}
