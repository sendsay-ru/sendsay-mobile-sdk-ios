//
//  SafeIndex.swift
//  SendsaySDK
//
//  Created by Ankmara on 24.02.2023.
//  Copyright © 2023 Sendsay. All rights reserved.
//

import Foundation

extension Array {
    subscript(safeIndex index: Int) -> Element? {
        if index < count && index >= 0 {
            return self[index]
        }
        return nil
    }
}
