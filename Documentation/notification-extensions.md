---
title: Notification extensions
excerpt: Configure application extensions required for certain push notification features in the iOS SDK.
slug: ios-sdk-notification-extensions
categorySlug: integrations
parentDocSlug: ios-sdk-push-notifications
---

To enable certain notification features supported by the iOS SDK, you must add either one or both of the following extensions to your application:

- A [notification service extension](https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension) — this type of extension lets you customize the content of a push notification before it's displayed to the user.
- A [notification content extension](https://developer.apple.com/documentation/usernotificationsui/unnotificationcontentextension) - this type of extension lets you customize the way a push notification is presented to the user.

Both extension types require the Sendsay Notification Service included in the SDK.

This page describes the steps to create an extension of either type. Make sure to follow the steps for each extension.

## Step 1: Create the extension

Navigate to `File` > `New` > `Target` in Xcode and select the extension type (`Notification Service Extension` or `Notification Content Extension`).

![Create new notification extension in Xcode](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/extension1.png)

> ❗️
>
>  Make sure that the `iOS Deployment Target` of your extension is the same as for your main app.


## Step 2: Configure SendsaySDK-Notifications dependency

Both extension types require a dependency on `SendsaySDK-Notification` so they can import `SendsayNotificationService`.

Follow the instructions in the relevant section for the dependency manager you use.

### CocoaPods

1. Add the following to the `Podfile` in the root folder of your Xcode project:
   ```
   target 'YourAppExtensionTarget' do
     pod 'SendsaySDK-Notifications'
   end
   ```
   (Replace `YourAppExtensionTarget` with your app extension target's name)
2. In a terminal window, navigate to your Xcode project folder and run the following command:
   ```
   pod install
   ```
3. Reopen the file `HelloWorld.xcworkspace`, located in your project folder, in XCode.

Optionally, you can specify the SendsaySDK version as follows to let `pod` automatically any smaller than minor version updates:
```
pod "SendsaySDK-Notifications", "~> 3.5.2"
```

### Carthage

Carthage will by default build both `SendsaySDK` and `SendsaySDKNotifications` frameworks.

1. In a terminal window, navigate to your Xcode project folder and run the following command:
    ```
    carthage update --use-xcframeworks —platform iOS
    ```
2. In your Xcode project, navigate to your app extension target's settings. 
3. On the `General` tab, in the `Frameworks, Libraries, and Embedded Content` section, click on `+` and add `SendsaySDKNotifications.xcframework`.

### Swift Package Manager

1. In your Xcode project, navigate to your app extension target's settings.
2. On the `General` tab, in the `Frameworks, Libraries, and Embedded Content` section, click on `+` and add `SendsaySDK-Notifications`.

## Step 3: Implement the extension

#### Notification service extension

This type of extension lets you customize the content of a push notification before it's displayed to the user.

Navigate to the extension's target, and on the `Signing & Capabilities` tab, add the `App Groups` capability, selecting the same group you used for your main app.

Open `NotificationService.swift` and replace its contents with the code below to call the `SendsayNotificationService`'s methods for processing notifications and handling timeouts.

``` swift
import UserNotifications
import SendsaySDKNotifications

class NotificationService: UNNotificationServiceExtension {
    let sendsayService = SendsayNotificationService(
        appGroup: "YOUR_APP_GROUP"
    )

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        sendsayService.process(request: request, contentHandler: contentHandler)
    }

    override func serviceExtensionTimeWillExpire() {
        sendsayService.serviceExtensionTimeWillExpire()
    }
}
```

> ❗️
>
> If you manage dependencies with CocoaPods or Swift Package Manager, you must use `import SendsaySDK_Notifications` instead of `import SendsaySDKNotifications` in the code above.

> 📘
>
> Refer to [ExampleNotificationService](https://github.com/sendsay/sendsay-ios-sdk/tree/main/SendsaySDK/ExampleNotificationService) in the [example app](https://documentation.bloomreach.com/engagement/docs/ios-sdk-example-app) for a reference implementation.

#### Notification content extension

This type of extension lets you customize the way a push notification is presented to the user.

A default storyboard file, `MainInterface.storyboard`, will be created. Delete it, you won't need it.

You'll now modify the default view controller implementation.

The service extension you created in the previous step will change the notification `categoryIdentifier` to `SENDSAY_ACTIONABLE`. You must configure the content extension to display push notifications with that category.

Open `Info.plist` in the content extension group.

- Under `NSExtension` > `NSExtensionAttributes`:
  - Set `UNNotificationExtensionCategory` to `SENDSAY_ACTIONABLE`.
- Under `NSExtension`:
  - Remove `NSExtensionMainStoryboard`.
  - Add `NSExtensionPrincipalClass` and set its value to your view controller class, for example, `TestingPushContentExtension.NotificationViewController`.

![Configure notification content extension in Xcode](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/extension3.png)

Notice the parameter `UNNotificationExtensionInitialContentSizeRatio` (with the default value 1). It specifies the ratio between the width and height of the content in the push notification. By default, the content is as high as it is wide. This setting is not part of the SDK but can cause unwanted blank space when no image is present. Change this value to 0 if you want the height to be dynamic (it will scale to the correct height if an image is present, but there will be no blank space if there is not).

Open `NotificationViewController.swift` and replace its contents with the code below so it forwards the notification to `SendsayNotificationContentService`, which will render the rich notification.

```swift
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
```

> ❗️
>
> If you manage dependencies with CocoaPods or Swift Package Manager, you must use `import SendsaySDK_Notifications` instead of ``import SendsaySDKNotifications`` in the code above.

> 📘
>
> Refer to [ExampleNotificationContent](https://github.com/sendsay/sendsay-ios-sdk/tree/main/SendsaySDK/ExampleNotificationContent) in the [example app](https://documentation.bloomreach.com/engagement/docs/ios-sdk-example-app) for a reference implementation.
