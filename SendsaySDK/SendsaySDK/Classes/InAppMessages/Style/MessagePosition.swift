//
//  MessagePosition.swift
//  SendsaySDK
//
//  Created by Ankmara on 18.03.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

public enum MessagePosition: Codable {
    case top
    case bottom
    case unknown

    public init(input: String?) {
        switch input?.lowercased() {
        case "top":
            self = .top
        case "bottom":
            self = .bottom
        default:
            self = .unknown
        }
    }
}
