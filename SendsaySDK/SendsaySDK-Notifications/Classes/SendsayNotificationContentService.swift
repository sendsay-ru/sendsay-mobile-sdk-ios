//
//  SendsayNotificationContentService.swift
//  SendsaySDK
//
//  Created by Dominik Hadl on 06/12/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import Foundation
import UserNotifications
import UserNotificationsUI
#if canImport(SendsaySDKShared)
import SendsaySDKShared
#endif

public class SendsayNotificationContentService {

    private let decoder: JSONDecoder = JSONDecoder.snakeCase

    private var attachmentUrl: URL?
    weak private var context: NSExtensionContext?

    public init() { }

    deinit {
        attachmentUrl?.stopAccessingSecurityScopedResource()
    }

    public func didReceive(_ notification: UNNotification,
                           context: NSExtensionContext?,
                           viewController: UIViewController) {
        guard Sendsay.isSendsayNotification(userInfo: notification.request.content.userInfo) else {
            Sendsay.logger.log(.verbose, message: "Skipping non-Sendsay notification")
            return
        }
        createActions(notification: notification, context: context)
        // Add image if any
        if let first = notification.request.content.attachments.first,
            first.url.startAccessingSecurityScopedResource() {
            attachmentUrl = first.url
            self.context = context
            createImageView(on: viewController.view, with: first.url.path)
        }
    }

    private func createActions(notification: UNNotification, context: NSExtensionContext?) {
        guard #available(iOS 12.0, *),
              let context = context,
              let actionsObject = notification.request.content.userInfo["actions"],
              let data = try? JSONSerialization.data(withJSONObject: actionsObject, options: []),
              let actions = try? decoder.decode([SendsayNotificationAction].self, from: data) else {
            return
        }
        context.notificationActions = []
        for (index, action) in actions.enumerated() {
            context.notificationActions.append(
                SendsayNotificationAction.createNotificationAction(
                    type: action.action,
                    title: action.title,
                    index: index
                )
            )
        }
    }

    private func createImageView(on view: UIView, with imagePath: String) {
        let url = URL(fileURLWithPath: imagePath)
        guard let data = try? Data(contentsOf: url) else {
            Sendsay.logger.log(.warning, message: "Unable to load image contents \(imagePath)")
            return
        }
        let imageView = UIImageView(image: UIImage.gif(data: data))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.imageTapped(gesture:))
        ))
        imageView.isUserInteractionEnabled = true
        view.addSubview(imageView)

        // Constraints
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
    }

    @objc
    public func imageTapped(gesture: UITapGestureRecognizer) {
        if #available(iOS 12.0, *) {
            context?.performNotificationDefaultAction()
        } else {
            // Fallback on earlier versions
        }
    }

}
