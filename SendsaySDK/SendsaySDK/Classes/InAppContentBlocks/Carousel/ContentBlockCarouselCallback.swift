//
//  ContentBlockCarouselCallback.swift
//  SendsaySDK
//
//  Created by Ankmara on 17.07.2024.
//  Copyright © 2024 Sendsay. All rights reserved.
//

import Foundation
import SafariServices

public protocol DefaultContentBlockCarouselCallback {
    var overrideDefaultBehavior: Bool { get set }
    var trackActions: Bool { get set }

    func onMessageShown(placeholderId: String, contentBlock: InAppContentBlockResponse, index: Int, count: Int)
    func onMessagesChanged(count: Int, messages: [InAppContentBlockResponse])
    func onNoMessageFound(placeholderId: String)
    func onError(placeholderId: String, contentBlock: InAppContentBlockResponse?, errorMessage: String)
    func onCloseClicked(placeholderId: String, contentBlock: InAppContentBlockResponse)
    func onActionClickedSafari(placeholderId: String, contentBlock: InAppContentBlockResponse, action: InAppContentBlockAction)
    func onHeightUpdate(placeholderId: String, height: CGFloat)
}

internal struct ContentBlockCarouselCallback: DefaultContentBlockCarouselCallback {

    var trackActions: Bool = true
    var overrideDefaultBehavior: Bool = false
    private var behaviourCallback: DefaultContentBlockCarouselCallback?

    init(behaviourCallback: DefaultContentBlockCarouselCallback?) {
        self.trackActions = behaviourCallback?.trackActions ?? true
        self.overrideDefaultBehavior = behaviourCallback?.overrideDefaultBehavior ?? false
        self.behaviourCallback = behaviourCallback
    }

    func onMessageShown(placeholderId: String, contentBlock: InAppContentBlockResponse, index: Int, count: Int) {
        Sendsay.logger.log(
            .verbose,
            message: "Tracking of Carousel Content Block \(contentBlock) show"
        )
        Sendsay.shared.trackInAppContentBlockShown(placeholderId: placeholderId, message: contentBlock)
        behaviourCallback?.onMessageShown(placeholderId: placeholderId, contentBlock: contentBlock, index: index, count: count)
    }

    func onMessagesChanged(count: Int, messages: [InAppContentBlockResponse]) {
        behaviourCallback?.onMessagesChanged(count: count, messages: messages)
    }

    func onNoMessageFound(placeholderId: String) {
        Sendsay.logger.log(.verbose, message: "Carousel Content Block has no content for \(placeholderId)")
        behaviourCallback?.onNoMessageFound(placeholderId: placeholderId)
    }

    func onError(placeholderId: String, contentBlock: InAppContentBlockResponse?, errorMessage: String) {
        guard let contentBlock else {
            Sendsay.logger.log(.error, message: "Carousel Content Block is empty!!! Nothing to track")
            return
        }
        Sendsay.logger.log(.verbose, message: "Tracking of Carousel Content Block \(contentBlock.id) error")
        Sendsay.shared.trackInAppContentBlockError(
            placeholderId: placeholderId,
            message: contentBlock,
            errorMessage: errorMessage
        )
        behaviourCallback?.onError(placeholderId: placeholderId, contentBlock: contentBlock, errorMessage: errorMessage)
    }

    func onCloseClicked(placeholderId: String, contentBlock: InAppContentBlockResponse) {
        Sendsay.logger.log(.verbose, message: "Tracking of Carousel Content Block \(contentBlock.id) close")
        if trackActions {
            Sendsay.shared.trackInAppContentBlockClose(
                placeholderId: placeholderId,
                message: contentBlock
            )
        }
        behaviourCallback?.onCloseClicked(placeholderId: placeholderId, contentBlock: contentBlock)
    }

    func onActionClickedSafari(
        placeholderId: String,
        contentBlock: InAppContentBlockResponse,
        action: InAppContentBlockAction
    ) {
        Sendsay.logger.log(.verbose, message: "Tracking of Carousel Content Block \(contentBlock.id) action \(action.name ?? "")")
        if action.type == .close {
            return
        }
        if trackActions {
            Sendsay.shared.trackInAppContentBlockClick(
                placeholderId: placeholderId,
                action: action,
                message: contentBlock
            )
        }
        if !overrideDefaultBehavior {
            if action.type == .browser {
                guard let stringUrl = action.url, let url = URL(safeString: stringUrl) else { return }
                let safari = SFSafariViewController(url: url)
                if let presented = UIApplication.shared.windows.first?.rootViewController?.presentedViewController {
                    presented.present(safari, animated: true)
                } else {
                    UIApplication.shared.windows.first?.rootViewController?.present(safari, animated: true)
                }
            } else {
                invokeAction(action, contentBlock)
            }
        }
        behaviourCallback?.onActionClickedSafari(placeholderId: placeholderId, contentBlock: contentBlock, action: action)
    }

    func onHeightUpdate(placeholderId: String, height: CGFloat) {
        Sendsay.logger.log(.verbose, message: "Carousel Content Block \(placeholderId) height update: \(height)")
        behaviourCallback?.onHeightUpdate(placeholderId: placeholderId, height: height)
    }

    private func invokeAction(_ action: InAppContentBlockAction, _ contentBlock: InAppContentBlockResponse) {
        Sendsay.logger.log(.verbose, message: "Invoking Carousel Content Block \(contentBlock.id) action '\(action.name ?? "")'")
        guard let actionUrl = action.url,
              action.type != .close else {
            return
        }
        let urlOpener = UrlOpener()
        switch action.type {
        case .deeplink:
            urlOpener.openDeeplink(actionUrl)
        case .browser:
            urlOpener.openBrowserLink(actionUrl)
        case .close:
            break
        case .unknown:
            Sendsay.logger.log(.error, message: "Invoking invalid type \(contentBlock.id) action '\(action.name ?? "")'")
        }
    }
}
