//
//  SendsayVersion.swift
//  SendsaySDK
//
//  Created by Panaxeo on 27/04/2022.
//  Copyright © 2022 Sendsay. All rights reserved.
//


import Foundation

final class SendsayVersion: SendsayVersionProvider {
    func getVersion() -> String {
        Sendsay.version as String
    }
}
