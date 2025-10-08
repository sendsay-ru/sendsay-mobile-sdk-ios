//
//  SegmentationStoring.swift
//  SendsaySDK
//
//  Created by Ankmara on 22.04.2024.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

@propertyWrapper
class SegmentationStoring {

    private let defaults = UserDefaults.standard
    private let defaultsName = "segment_store"

    var wrappedValue: SegmentStore? {
        get {
            SegmentStore(data: defaults.value(forKey: defaultsName) as? String)
        }
        set {
            defaults.setValue(newValue?.toBase64Json, forKey: defaultsName)
        }
    }
}
