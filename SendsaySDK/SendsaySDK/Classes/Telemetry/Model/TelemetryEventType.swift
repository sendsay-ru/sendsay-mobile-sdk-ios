//
//  TelemetryEventType.swift
//  SendsaySDK
//
//  Created by Panaxeo on 13/03/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

import Foundation

enum TelemetryEventType: String {
    case initialize = "init"
    case fetchRecommendation
    case fetchConsents
    case showInAppMessage
    case selfCheck
    case anonymize
    case eventCount
    case fetchAppInbox
}
