//
//  MockInAppMessagesManager.swift
//  SendsaySDKTests
//
//  Created by Panaxeo on 03/09/2020.
//  Copyright © 2020 Sendsay. All rights reserved.
//

@testable import SendsaySDK

final class MockInAppMessagesManager: InAppMessagesManagerType {
    func isFetchInAppMessagesDone(for event: [SendsaySDK.DataType]) async throws -> Bool {
        true
    }
    
    func startIdentifyCustomerFlow(for event: [SendsaySDK.DataType], isFromIdentifyCustomer: Bool, isFetchDisabled: Bool, isAnonymized: Bool, triggerCompletion: SendsaySDK.TypeBlock<SendsaySDK.IdentifyTriggerState>?) {
        
    }
    
    func startIdentifyCustomerFlow(for event: [SendsaySDK.DataType], isFromIdentifyCustomer: Bool, isFetchDisabled: Bool, triggerCompletion: SendsaySDK.TypeBlock<SendsaySDK.IdentifyTriggerState>?) {}
    func addToPendingShowRequest(event: [SendsaySDK.DataType]) {}
    func loadMessagesToShow(for event: [SendsaySDK.DataType]) -> [SendsaySDK.InAppMessage] { [] }
    func showInAppMessage(for type: [SendsaySDK.DataType], callback: ((SendsaySDK.InAppMessageView?) -> Void)?) {}
    func fetchInAppMessages(for event: [SendsaySDK.DataType], completion: SendsaySDK.EmptyBlock?) {}
    func loadMessageToShow(
        for event: [SendsaySDK.DataType]
    ) -> SendsaySDK.InAppMessage? { nil }
    var sessionStartDate: Date = .init()
    func onEventOccurred(
        of type: SendsaySDK.EventType,
        for event: [SendsaySDK.DataType],
        triggerCompletion: SendsaySDK.TypeBlock<SendsaySDK.IdentifyTriggerState>?
    ) {}
    var pendingShowRequests: [String: SendsaySDK.InAppMessagesManager.InAppMessageShowRequest] = [:]
    func sessionDidStart(at date: Date, for customerIds: [String: String], completion: (() -> Void)?) {}
    func anonymize() {}
    private var delegateValue: InAppMessageActionDelegate = DefaultInAppDelegate()
    internal var delegate: InAppMessageActionDelegate {
        get {
            return delegateValue
        }
        set {
            delegateValue = newValue
        }
    }
    func trackInAppMessageClick(
        _ message: InAppMessage,
        buttonText: String?,
        buttonLink: String?
    ) {}

    func trackInAppMessageClose(
        _ message: InAppMessage
    ) {}

    func onEventOccurred(of type: EventType, for event: [SendsaySDK.DataType]) {}
}
