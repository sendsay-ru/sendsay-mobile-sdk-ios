//
//  AppInboxListViewStyle.swift
//  SendsaySDK
//
//  Created by Adam Mihalik on 19/05/2023.
//  Copyright © 2023 Sendsay. All rights reserved.
//

import Foundation
import UIKit

public class AppInboxListViewStyle {
    var backgroundColor: String?
    var item: AppInboxListItemStyle?

    public init(
        backgroundColor: String? = nil,
        item: AppInboxListItemStyle? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.item = item
    }

    public func applyTo(_ target: UITableView) {
        if let backgroundColor = UIColor.parse(backgroundColor) {
            target.backgroundColor = backgroundColor
        }
        // note: 'item' style is used elsewhere due to performance reasons
    }
}
