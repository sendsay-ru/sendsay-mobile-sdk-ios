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
        let currentDateTime = dateFormatter.string(from: Date())

        let clearBasketInfo: [String: JSONConvertible] = [
            "ssec": [
                "dt": currentDateTime,
                "items": [
                    ["id": -1]
                ]
            ]
        ]

        // Отправка события
        Sendsay.shared.trackEvent(
            properties: clearBasketInfo,
            timestamp: nil,
            eventType: "ssec_basket_clear"
        )
    }

    @IBAction func trackProductView(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDateTime = dateFormatter.string(from: Date())

        let productViewInfo: [String: JSONConvertible] = [
            "ssec": [
                "dt": currentDateTime,
                "id": "product1",
                "available": 1,
                "name": "name",
                "price": 7.88,
                "old_price": 5.99,
                "picture": [],
                "url": "url",
                "model": "model",
                "vendor": "vendor",
                "category_id": 777,
                "category": "category name"
            ]
        ]

        // Отправка события
        Sendsay.shared.trackEvent(
            properties: productViewInfo,
            timestamp: nil,
            eventType: "ssec_product_view"
        )
    }

    @IBAction func trackOrder() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDateTime = dateFormatter.string(from: Date())

        let randomTransactionId = UUID().uuidString

        let productOrder: [String: JSONConvertible] = [
            "ssec": [
                "dt": currentDateTime,
                "transaction_id": randomTransactionId,
                "transaction_dt": currentDateTime,
                "transaction_sum": 100.9,
                "update_per_item": 0,
                "items": [
                    [
                        "id": "product1",
                        "available": 1,
                        "name": "name",
                        "qnt": 1,
                        "price": 7.88,
                        "old_price": 5.99,
                        "picture": [],
                        "url": "url",
                        "model": "model",
                        "vendor": "vendor",
                        "category_id": 777,
                        "category": "category name"
                    ]
                ]
            ]
        ]

        // Отправка события
        Sendsay.shared.trackEvent(
            properties: productOrder,
            timestamp: nil,
            eventType: "ssec_order"
        )
    }

    @IBAction func trackBasket() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDateTime = dateFormatter.string(from: Date())

        let productBasket: [String: JSONConvertible] = [
            "ssec": [
                "dt": currentDateTime,
                "transaction_sum": 100.9,
                "update_per_item": 0,
                "items": [
                    [
                        "id": "product1",
                        "available": 1,
                        "name": "name",
                        "qnt": 1,
                        "price": 7.88,
                        "old_price": 5.99,
                        "picture": [],
                        "url": "url",
                        "model": "model",
                        "vendor": "vendor",
                        "category_id": 777,
                        "category": "category name"
                    ]
                ]
            ]
        ]

        // Отправка события
        Sendsay.shared.trackSSEC(placeholderId: <#T##String#>, messsage: <#T##MessageItem#>)
        Sendsay.shared.trackEvent(
            properties: productBasket,
            timestamp: nil,
            eventType: "ssec_basket"
        )
    }
}
