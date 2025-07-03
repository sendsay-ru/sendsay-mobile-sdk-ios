//
//  InAppMessagesRequest.swift
//  SendsaySDK
//
//  Created by Panaxeo on 28/11/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

import Foundation

struct InAppMessagesRequest: Codable, RequestParametersType {
    var parameters: [String: JSONValue] {
        return [
            "device": "ios".jsonValue
        ]
    }
}
