//
//  IntegrationManager.swift
//  SendsaySDK
//
//  Created by Ankmara on 06.03.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

public class IntegrationManager {
    public static let shared = IntegrationManager()
    public var onIntegrationStoppedCallbacks: [EmptyBlock] = []
    internal var isStopped: Bool = false {
        willSet {
            UserDefaults(suiteName: Sendsay.shared.configuration?.appGroup ?? Constants.General.userDefaultsSuite)?.set(newValue, forKey: "isStopped")
        }
    }
    private init() {}
}
