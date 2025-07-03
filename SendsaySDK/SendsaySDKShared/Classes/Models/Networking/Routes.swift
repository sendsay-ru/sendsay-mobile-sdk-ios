//
//  Routes.swift
//  SendsaySDKShared
//
//  Created by Ricardo Tokashiki on 20/04/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation

/// Identification of endpoints for Sendsay API
public enum Routes {
    case identifyCustomer
    case customEvent
    case customerAttributes
    case campaignClick
    case consents
    case inAppMessages
    case pushSelfCheck
    case appInbox
    case appInboxMarkRead
    case inAppContentBlocks
    case personalizedInAppContentBlocks
    case segmentation(cookie: String)
    case linkIds(cookie: String)

    public var method: HTTPMethod {
        switch self {
        case .consents, .inAppContentBlocks, .segmentation: return .get
        default: return .post
        }
    }
}
