//
//  InitConfigResponse.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 18.07.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

public struct InitConfigResponse: Codable {
    /// Contains an Init Configuration Item.
    public let results: ConfigItem
    /// If the request was successful.
    public let success: Bool
}

private extension InitConfigResponse {
    enum CodingKeys: String, CodingKey {
        case results = "results"
        case success
    }
}
