//
//  TelemetryUpload.swift
//  SendsaySDK
//
//  Created by Panaxeo on 15/11/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

protocol TelemetryUpload: AnyObject {
    func removeAll()
    func upload(crashLog: CrashLog, completionHandler: @escaping (Bool) -> Void)
    func upload(eventWithName: String, properties: [String: String], completionHandler: @escaping (Bool) -> Void)
}
