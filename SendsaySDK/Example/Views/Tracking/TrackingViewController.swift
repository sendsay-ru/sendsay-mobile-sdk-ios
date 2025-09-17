//
//  TrackingViewController.swift
//  Example
//
//  Created by Dominik Hadl on 25/05/2018.
//  Copyright © 2018 Sendsay. All rights reserved.
//

import UIKit
import SendsaySDK
import UserNotifications

class TrackingViewController: UIViewController {
    @IBOutlet weak var trackProductButton: UIButton!
    @IBOutlet weak var trackOrderButton: UIButton!
    @IBOutlet weak var trackBasketButton: UIButton!
    @IBOutlet weak var trackClearBasketButton: UIButton!

    @IBOutlet weak var automaticSessionTrackingSwitch: UISwitch!
    @IBOutlet weak var sessionStartButton: UIButton!
    @IBOutlet weak var sessionEndButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let config = Sendsay.shared.configuration {
            automaticSessionTrackingSwitch.setOn(config.automaticSessionTracking, animated: true)
            sessionStartButton.isEnabled = !config.automaticSessionTracking
            sessionEndButton.isEnabled = !config.automaticSessionTracking
        }

        SegmentationManager.shared.addCallback(
            callbackData: .init(
                category: .discovery(),
                isIncludeFirstLoad: true,
                onNewData: { segments in
                    print(segments)
                }))
    }

    @IBAction func paymentPressed(_ sender: Any) {
        Sendsay.shared.trackPayment(properties: ["value": "99", "custom_info": "sample payment"], timestamp: nil)
    }

    @IBAction func registerForPush() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, _) in
            // Enable or disable features based on authorization.
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    @available(iOS 12.0, *)
    @IBAction func registerForProvisionalPush() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.provisional, .badge, .alert, .sound]) { (granted, _) in
            // Enable or disable features based on authorization.
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    @IBAction func campaignClickPressed(_ sender: Any) {
        // swiftlint:disable:next line_length
        if let url = URL(safeString: "https://panaxeo.com/sendsay/product.html?iitt=VuU9RM4lhMPshFWladJLVZ8ARMWsVuegnkU7VkichfYcbdiA&utm_campaign=Test%20direct%20links&utm_source=sendsay&utm_medium=email&xnpe_cmp=EiAHASXwhARMc-4pi3HQKTynsFBXa54EjBjb-qh2HAv3kSEpscfCI2HXQQ.XlWYaES2X-r8Nlv4J22eO0M3Rgk") {
            Sendsay.shared.trackCampaignClick(url: url, timestamp: nil)
        }
    }

    @IBAction func trackPushNotifReceived(_ sender: Any) {
        let userInfo: [AnyHashable: Any] = [
            "url": "https://example.com/ios",
            "title": "iOS Title",
            "action": "app",
            "message": "iOS Message",
            "image": "https://example.com/image.jpg",
            "actions": [
                ["title": "Action 1", "action": "app", "url": "https://example.com/action1/ios"],
                ["title": "Action 2", "action": "browser", "url": "https://example.com/action2/ios"]
            ],
            "sound": "default",
            "aps": [
                "alert": ["title": "iOS Alert Title", "body": "iOS Alert Body"],
                "mutable-content": 1
            ],
            "attributes": [
                "event_type": "campaign",
                "campaign_id": "123456",
                "campaign_name": "iOS Campaign",
                "action_id": 1,
                "action_type": "mobile notification",
                "action_name": "iOS Action",
                "campaign_policy": "policy",
                "consent_category": "General consent",
                "subject": "iOS Subject",
                "language": "en",
                "platform": "ios",
                "sent_timestamp": 1631234567.89,
                "recipient": "ios@example.com"
            ],
            "url_params": ["param1": "value1", "param2": "value2"],
            "source": "xnpe_platform",
            "silent": false,
            "has_tracking_consent": true,
            "consent_category_tracking": "iOS Consent"
        ]
        Sendsay.shared.trackPushReceived(userInfo: userInfo)
    }

    @IBAction func trackPushNotifClick(_ sender: Any) {
        let userInfo: [AnyHashable: Any] = [
            "url": "https://example.com/ios",
            "title": "iOS Title",
            "action": "app",
            "message": "iOS Message",
            "image": "https://example.com/image.jpg",
            "actions": [
                ["title": "Action 1", "action": "app", "url": "https://example.com/action1/ios"],
                ["title": "Action 2", "action": "browser", "url": "https://example.com/action2/ios"]
            ],
            "sound": "default",
            "aps": [
                "alert": ["title": "iOS Alert Title", "body": "iOS Alert Body"],
                "mutable-content": 1
            ],
            "attributes": [
                "event_type": "campaign",
                "campaign_id": "123456",
                "campaign_name": "iOS Campaign",
                "action_id": 1,
                "action_type": "mobile notification",
                "action_name": "iOS Action",
                "campaign_policy": "policy",
                "consent_category": "General consent",
                "subject": "iOS Subject",
                "language": "en",
                "platform": "ios",
                "sent_timestamp": 1631234567.89,
                "recipient": "ios@example.com"
            ],
            "url_params": ["param1": "value1", "param2": "value2"],
            "source": "xnpe_platform",
            "silent": false,
            "has_tracking_consent": true,
            "consent_category_tracking": "iOS Consent"
        ]
        Sendsay.shared.trackPushOpened(with: userInfo)
    }

    @IBAction func automaticSessionTrackingChanged(_ sender: UISwitch) {
        let automaticSessionTracking = sender.isOn ?
        Sendsay.AutomaticSessionTracking.enabled() : Sendsay.AutomaticSessionTracking.disabled
        Sendsay.shared.setAutomaticSessionTracking(automaticSessionTracking: automaticSessionTracking)
        if let config = Sendsay.shared.configuration {
            sessionStartButton.isEnabled = !config.automaticSessionTracking
            sessionEndButton.isEnabled = !config.automaticSessionTracking
        }
    }
    @IBAction func sessionStartPressed(_ sender: UIButton) {
        Sendsay.shared.trackSessionStart()
    }

    @IBAction func sessionEndPressed(_ sender: UIButton) {
        Sendsay.shared.trackSessionEnd()
    }

    @IBAction func trackClearBasket() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDateTime = Date()
        
        let clearBasketInfo: TrackSSECData?
        
        do {
            clearBasketInfo = try TrackSSECDataBuilder(type: .basketClear)
                .setTransaction(dt: dateFormatter.string(from: currentDateTime))
                .setItems([
                    OrderItem(id: "-1")
                ])
                .build()
            
//            let clearBasketInfoJSON: [String: Any] = [
//                "dt": currentDateTime,
//                "items": [
//                    ["id": -1]
//                ]
//            ]
//            clearBasketInfo = try TrackSSECData.fromJSON(clearBasketInfoJSON)

            // Отправка события
            Sendsay.shared.trackEvent(
                properties: clearBasketInfo!.toSsecProps(),
                timestamp: nil,
                eventType: TrackingSSECType.basketClear.rawValue
            )
        } catch {
            Sendsay.logger.log(.error, message: "trackClearBasket parse error: \(error)")
        }
    }

    @IBAction func trackProductView(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDateTime = Date()
        
        let productViewInfo: TrackSSECData?

        do {
            productViewInfo = try TrackSSECDataBuilder(type: .viewProduct)
                .setProduct(id: "product1",
                            name: "name",
                            dateTime: dateFormatter.string(from: currentDateTime),
                            picture: [],
                            url: "url",
                            available: 1,
                            categoryId: 777,
                            category: "category name",
                            vendor: "vendor",
                            model: "model",
                            price: 7.88,
                            oldPrice: 5.99)
                .build()
            
//            let productViewInfoJSON: [String: Any] = [
//                "dt": currentDateTime,
//                "id": "product1",
//                "available": 1,
//                "name": "name",
//                "price": 7.88,
//                "old_price": 5.99,
//                "picture": [],
//                "url": "url",
//                "model": "model",
//                "vendor": "vendor",
//                "category_id": 777,
//                "category": "category name"
//            ]
//            productViewInfo = try TrackSSECData.fromJSON(productViewInfoJSON)

            // Отправка события
            Sendsay.shared.trackSSEC(
                properties: productViewInfo!.toSsecProps(),
                timestamp: nil,
                eventType: TrackingSSECType.viewProduct.rawValue
            )
        } catch {
            Sendsay.logger.log(.error, message: "Error trackPorduct: \(error.localizedDescription)")
        }
    }

    @IBAction func trackOrder() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDateTime = Date()
        let formattedDT = dateFormatter.string(from: currentDateTime)
        let randomTransactionId = UUID().uuidString

        let productOrder: TrackSSECData?

        do {
            productOrder = try TrackSSECDataBuilder(type: .order)
                .setProduct(dateTime: formattedDT)
                .setTransaction(id: randomTransactionId, dt: formattedDT, sum: 100.9)
                .setUpdate(isUpdatePerItem: false)
                .setItems([
                    OrderItem(
                        id: "product1",
                        qnt: 1,
                        price: 7.88,
                        available: 1,
                        oldPrice: 5.99,
                        picture: [],
                        url: "url",
                        model: "model",
                        vendor: "vendor",
                        categoryId: 777,
                        category: "category name"
                    )
                ])
                .build()
            
//            let productOrderJSON: [String: Any] = [
//                "dt": currentDateTime,
//                "transaction_id": randomTransactionId,
//                "transaction_dt": currentDateTime,
//                "transaction_sum": 100.9,
//                "update_per_item": 0,
//                "items": [
//                    [
//                        "id": "product1",
//                        "available": 1,
//                        "name": "name",
//                        "qnt": 1,
//                        "price": 7.88,
//                        "old_price": 5.99,
//                        "picture": [],
//                        "url": "url",
//                        "model": "model",
//                        "vendor": "vendor",
//                        "category_id": 777,
//                        "category": "category name"
//                    ]
//                ]
//            ]
//            productOrder = try TrackSSECData.fromJSON(productOrderJSON)

            // Отправка события
            Sendsay.shared.trackSSEC(
                properties: productOrder!.toSsecProps(),
                timestamp: nil,
                eventType: TrackingSSECType.order.rawValue
            )
        } catch {
            Sendsay.logger.log(.error, message: "Error trackOrder: \(error.localizedDescription)")
        }
    }

    @IBAction func trackBasket() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDateTime = Date()
        let formattedDT = dateFormatter.string(from: currentDateTime)
        let randomTransactionId = UUID().uuidString

        let data: TrackSSECData?

        do {
            data = try TrackSSECDataBuilder(type: .basketAdd)
                .setProduct(dateTime: formattedDT)
                .setTransaction(id: randomTransactionId, sum: 100.9)
                .setUpdate(isUpdatePerItem: false)
                .setItems([
                    OrderItem(
                        id: "product1",
                        qnt: 1,
                        price: 7.88,
                        available: 1,
                        oldPrice: 5.99,
                        picture: [],
                        url: "url",
                        model: "model",
                        vendor: "vendor",
                        categoryId: 777,
                        category: "category name"
                    )
                ])
                .build()

//            let productBasketJson: [String: Any] = [
//                    "dt": currentDateTime,
//                    "transaction_sum": 100.9,
//                    "update_per_item": 0,
//                    "items": [
//                        [
//                            "id": "product1",
//                            "available": 1,
//                            "name": "name",
//                            "qnt": 1,
//                            "price": 7.88,
//                            "old_price": 5.99,
//                            "picture": [],
//                            "url": "url",
//                            "model": "model",
//                            "vendor": "vendor",
//                            "category_id": 777,
//                            "category": "category name"
//                        ]
//                    ]
//                ]
//            data = try TrackSSECData.fromJSON(productBasketJson)

            // Отправка события
            Sendsay.shared.trackSSEC(
                properties: data!.toSsecProps(),
                timestamp: currentDateTime.timeIntervalSince1970,
                eventType: TrackingSSECType.basketAdd.rawValue
            )
        } catch {
            Sendsay.logger.log(.error, message: "Error trackBasket: \(error.localizedDescription)")
        }
    }
}
