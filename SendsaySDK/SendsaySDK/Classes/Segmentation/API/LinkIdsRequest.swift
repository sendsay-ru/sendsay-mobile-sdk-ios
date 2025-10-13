//
//  LinkIdsRequest.swift
//  SendsaySDK
//
//  Created by Ankmara on 19.04.2024.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

struct LinkIdsRequest: Codable, RequestParametersType {
    var externalIds: [String: String]
    var parameters: [String: JSONValue] {
        [:]
    }
    var requestParameters: [String: Any] {
        ["external_ids": externalIds]
    }
}
