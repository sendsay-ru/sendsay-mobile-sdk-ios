//
//  StaticInAppContentBlockViewSpec.swift
//  SendsaySDKTests
//
//  Created by Adam Mihalik on 02/02/2024.
//  Copyright © 2024 Sendsay. All rights reserved.
//

import Foundation
import Quick
import Nimble
import WebKit

@testable import SendsaySDK

class StaticInAppContentBlockViewSpec: QuickSpec {
    let configuration = try! Configuration(
        projectToken: "token",
        authorization: Authorization.none,
        baseUrl: "baseUrl"
    )
    override func spec() {
        it("should NOT invoke error event for about:blank action URL") {
            let view = StaticInAppContentBlockView(placeholder: "ph_1", deferredLoad: true)
            var errorCalled = false
            view.behaviourCallback = SimpleBehaviourCallback(
                onErrorAction: { _, _, _ in
                    errorCalled = true
                }
            )
            let action = SimpleNavigationAction(url: URL(string: "about:blank")!)
            var actionHasBeenHandled: Bool?
            view.webView(WKWebView(), decidePolicyFor: action) { decision in
                // canceled action means that action has been handled internaly, WebView is not allowed to continue
                actionHasBeenHandled = decision == .cancel
            }
            expect(actionHasBeenHandled).toNot(beNil())
            guard let actionHasBeenHandled = actionHasBeenHandled else {
                return
            }
            expect(actionHasBeenHandled).to(beFalse())
            expect(errorCalled).to(beFalse())
        }
    }
}

class SimpleBehaviourCallback: InAppContentBlockCallbackType {

    func onActionClickedSafari(placeholderId: String, contentBlock: SendsaySDK.InAppContentBlockResponse, action: SendsaySDK.InAppContentBlockAction) {
        
    }

    private var onMessageShownAction: ((String, SendsaySDK.InAppContentBlockResponse) -> Void)?
    private var onNoMessageFoundAction: ((String) -> Void)?
    private var onErrorAction: ((String, SendsaySDK.InAppContentBlockResponse?, String) -> Void)?
    private var onCloseClickedAction: ((String, SendsaySDK.InAppContentBlockResponse) -> Void)?
    private var onActionClickedAction: ((String, SendsaySDK.InAppContentBlockResponse, SendsaySDK.InAppContentBlockAction) -> Void)?
    init(
        onMessageShownAction: ((String, SendsaySDK.InAppContentBlockResponse) -> Void)? = nil,
        onNoMessageFoundAction: ((String) -> Void)? = nil,
        onErrorAction: ((String, SendsaySDK.InAppContentBlockResponse?, String) -> Void)? = nil,
        onCloseClickedAction: ((String, SendsaySDK.InAppContentBlockResponse) -> Void)? = nil,
        onActionClickedAction: ((String, SendsaySDK.InAppContentBlockResponse, SendsaySDK.InAppContentBlockAction) -> Void)? = nil
    ) {
        self.onMessageShownAction = onMessageShownAction
        self.onNoMessageFoundAction = onNoMessageFoundAction
        self.onErrorAction = onErrorAction
        self.onCloseClickedAction = onCloseClickedAction
        self.onActionClickedAction = onActionClickedAction
    }
    func onMessageShown(placeholderId: String, contentBlock: SendsaySDK.InAppContentBlockResponse) {
        onMessageShownAction?(placeholderId, contentBlock)
    }
    func onNoMessageFound(placeholderId: String) {
        onNoMessageFoundAction?(placeholderId)
    }
    func onError(placeholderId: String, contentBlock: SendsaySDK.InAppContentBlockResponse?, errorMessage: String) {
        onErrorAction?(placeholderId, contentBlock, errorMessage)
    }
    func onCloseClicked(placeholderId: String, contentBlock: SendsaySDK.InAppContentBlockResponse) {
        onCloseClickedAction?(placeholderId, contentBlock)
    }
    
    func onActionClicked(placeholderId: String, contentBlock: SendsaySDK.InAppContentBlockResponse, action: SendsaySDK.InAppContentBlockAction) {
        onActionClickedAction?(placeholderId, contentBlock, action)
    }
}

final class SimpleNavigationAction: WKNavigationAction {
    let urlRequest: URLRequest
    var receivedPolicy: WKNavigationActionPolicy?
    override var request: URLRequest { urlRequest }
    init(
        urlRequest: URLRequest
    ) {
        self.urlRequest = urlRequest
        super.init()
    }
    convenience init(url: URL) {
        self.init(urlRequest: URLRequest(url: url))
    }
    func decisionHandler(_ policy: WKNavigationActionPolicy) { self.receivedPolicy = policy }
}
