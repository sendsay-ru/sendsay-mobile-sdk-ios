//
//  InAppButtonMarginType.swift
//  SendsaySDK
//
//  Created by Ankmara on 18.03.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

public enum InAppButtonMarginType: String, Codable {
    case leading
    case top
    case trailing
    case bottom
    case unknown

    init(input: String?) {
        switch input?.lowercased() {
        case "top":
            self = .top
        case "left":
            self = .leading
        case "bottom":
            self = .bottom
        case "right":
            self = .trailing
        default:
            self = .unknown
        }
    }
}
