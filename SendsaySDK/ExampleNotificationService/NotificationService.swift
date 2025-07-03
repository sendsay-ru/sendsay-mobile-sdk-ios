//
//  NotificationService.swift
//  ExampleNotificationService
//
//  Created by Dominik Hadl on 22/11/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import UserNotifications
import SendsaySDKNotifications

class NotificationService: UNNotificationServiceExtension {

    let sendsayService = SendsayNotificationService(appGroup: "group.com.sendsay.SendsaySDK-Example2")

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        sendsayService.process(request: request, contentHandler: contentHandler)
    }

    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise
    // the original push payload will be used.
    override func serviceExtensionTimeWillExpire() {
        sendsayService.serviceExtensionTimeWillExpire()
    }
}
