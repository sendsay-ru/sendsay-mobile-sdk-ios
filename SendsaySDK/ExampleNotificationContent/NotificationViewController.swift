//
//  NotificationViewController.swift
//  ExampleNotificationContent
//
//  Created by Dominik Hadl on 06/12/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import SendsaySDKNotifications

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    let sendsayService = SendsayNotificationContentService()

    func didReceive(_ notification: UNNotification) {
        sendsayService.didReceive(notification, context: extensionContext, viewController: self)
    }
}
