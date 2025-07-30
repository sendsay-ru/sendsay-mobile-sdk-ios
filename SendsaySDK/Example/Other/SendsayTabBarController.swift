//
//  SendsayTabBarController.swift
//  Example
//
//  Created by Ankmara on 07.08.2023.
//  Copyright © 2023 Sendsay. All rights reserved.
//

import UIKit

enum TabbarItem {

//    case fetch
    case tracking
    case flush
    case anonymize
//    case contentBlocks
    case logging

    var index: Int {
        switch self {
//        case .fetch:
//            return 0
        case .tracking:
            return 1
        case .flush:
            return 2
        case .anonymize:
            return 3
//        case .contentBlocks:
//            return 4
        case .logging:
            return 5
        }
    }
}

final class SendsayTabBarController: UITabBarController {
    var coordinator: Coordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Откладываем настройку до появления moreNavigationController
        DispatchQueue.main.async {
            if let navController = self.moreNavigationController as UINavigationController?,
               let topItem = navController.navigationBar.topItem {
                topItem.rightBarButtonItem?.title = ""
                topItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }
}
