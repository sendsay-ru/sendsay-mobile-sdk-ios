//
//  TelemetryStorage.swift
//  SendsaySDK
//
//  Created by Panaxeo on 15/11/2019.
//  Copyright © 2019 Sendsay. All rights reserved.
//

protocol TelemetryStorage {
    func saveCrashLog(_ log: CrashLog)
    func deleteCrashLog(_ log: CrashLog)
    func getAllCrashLogs() -> [CrashLog]
}
