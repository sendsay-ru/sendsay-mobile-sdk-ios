//
//  Sendsay.swift
//  SendsaySDKShared
//
//  Created by Panaxeo on 05/03/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

import Foundation

public class Sendsay {
    public static let version = "3.5.2"
    /// A logger used to log all messages from the SDK.
    public static var logger: Logger = Logger()

    public static func isSendsayNotification(userInfo: [AnyHashable: Any]) -> Bool {
        return userInfo["source"] as? String == "xnpe_platform"
    }
}
