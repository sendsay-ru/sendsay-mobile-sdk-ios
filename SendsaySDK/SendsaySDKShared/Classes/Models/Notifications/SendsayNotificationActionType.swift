//
//  SendsayNotificationActionType.swift
//  SendsaySDKShared
//
//  Created by Dominik Hadl on 25/11/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation

public enum SendsayNotificationActionType: String, Codable {
    case openApp = "app"
    case browser = "browser"
    case deeplink = "deeplink"
    case selfCheck = "self-check"
    case none = ""

    var identifier: String {
        switch self {
        case .openApp: return "SENDSAY_ACTION_APP"
        case .browser: return "SENDSAY_ACTION_BROWSER"
        case .deeplink: return "SENDSAY_ACTION_DEEPLINK"
        default: return ""
        }
    }

    init?(identifier: String) {
        switch identifier {
        case "SENDSAY_ACTION_APP": self = .openApp
        case "SENDSAY_ACTION_BROWSER": self = .browser
        case "SENDSAY_ACTION_DEEPLINK": self = .deeplink
        default: return nil
        }
    }
}
