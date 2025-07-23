//
//  InitConfigManagerType.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 21.07.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

protocol InitConfigManagerType {

    var inRefetchCallback: Void? { get set }

    var sessionStartDate: Date { get set }
}

/// Result of fetch operation
public enum InitConfigResult {
    case success(ConfigItem)
    // Unable to fetch, we're not connected to internet
    case noInternetConnection
    // Unexpected error occured during fetching
    case error(Error)
}
