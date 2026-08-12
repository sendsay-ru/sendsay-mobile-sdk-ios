---
title: Расширения уведомлений
excerpt: Настройка расширений приложения, необходимых для определённых функций push-уведомлений в iOS SDK.
slug: ios-sdk-notification-extensions
categorySlug: integrations
parentDocSlug: ios-sdk-push-notifications
---

Некоторые функции push-уведомлений в iOS SDK требуют добавления в приложение одного или двух расширений:

- [Notification Service Extension](https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension) — позволяет настроить содержимое уведомления перед его показом.
- [Notification Content Extension](https://developer.apple.com/documentation/usernotificationsui/unnotificationcontentextension) — отвечает за настройку способа отображения уведомления.

Оба расширения используют Sendsay Notification Service, который входит в SDK.

Ниже описаны шаги для настройки каждого расширения. Если вам нужны оба типа, выполните инструкции для каждого отдельно.

## Шаг 1: Создание расширения

В Xcode выберите **File** > **New** > **Target** и создайте расширение нужного типа (**Notification Service Extension** или **Notification Content Extension**).

![Создание нового расширения уведомлений в Xcode](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/extension1.png)

> ❗️
>
> Убедитесь, что `iOS Deployment Target` расширения совпадает с `target` основного приложения.

## Шаг 2: Настройка зависимости SendsaySDK-Notifications

Оба типа расширений должны зависеть от `SendsaySDK-Notification`, чтобы импортировать `SendsayNotificationService`.

Следуйте инструкциям для вашего менеджера зависимостей.

### CocoaPods

1. Добавьте зависимость в **Podfile**, в корневой папке вашего проекта Xcode:
   ```
   target 'YourAppExtensionTarget' do
     pod 'SendsaySDK-Notifications'
   end
   ```
   Замените `YourAppExtensionTarget` на таргет расширения вашего приложения.

2. В окне терминала перейдите в папку проекта Xcode и выполните команду для установки зависимости:
   ```
   pod install
   ```

3. Повторно откройте файл **HelloWorld.xcworkspace**, расположенный в папке вашего проекта в XCode.

Чтобы разрешить автоматические обновления меньше минорной версии:
```
pod "SendsaySDK-Notifications", "~> 3.6.0"
```

### Swift Package Manager

1. В вашем проекте Xcode откройте настройки таргета расширения.
2. На вкладке **General**, в разделе **Frameworks, Libraries, and Embedded Content**, нажмите на «+» и добавьте `SendsaySDK-Notifications`.

## Шаг 3: Реализация расширения

#### Notification Service Extension

Это расширение позволяет настроить содержимое push-уведомления перед тем, как оно будет показано пользователю.

1. В таргете расширения откройте вкладку **Signing & Capabilities** добавьте возможность `App Groups` — ту же, что использует основное приложение.

2. Откройте файл **NotificationService.swift** и замените содержимое:

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
> Если вы используйте CocoaPods или Swift Package Manager, импорт должен выглядеть так: `import SendsaySDK_Notifications`.

> 📘
>
> Обратитесь к [ExampleNotificationService](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/tree/main/SendsaySDK/ExampleNotificationService) в [примере приложения](example-app.md) для эталонной реализации.

#### Notification Content Extension

Это расширение определяет, как push-уведомление будет отображаться пользователю.

1. Удалите созданный по умолчанию `MainInterface.storyboard` — он не понадобится.

2. SDK меняет `categoryIdentifier` уведомления на `SENDSAY_ACTIONABLE`. Чтобы расширение отображалось для таких уведомлений, настройте `Info.plist` расширения:
    - Под `NSExtension` > `NSExtensionAttributes`:
        - Установите `UNNotificationExtensionCategory` в `SENDSAY_ACTIONABLE`.
    - Под `NSExtension`:
        - Удалите `NSExtensionMainStoryboard`.
        - Добавьте `NSExtensionPrincipalClass` и установите его значение в класс вашего контроллера представления, например, `TestingPushContentExtension.NotificationViewController`.

    ![Настройка расширения контента уведомлений в Xcode](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/extension3.png)


    > ❗️ Параметр высоты контента
    >
    > Параметр `UNNotificationExtensionInitialContentSizeRatio` (по умолчанию — 1) задаёт пропорции высоты и ширины контента в уведомлении.

    Если в уведомлении отсутствует изображение, может появиться пустое пространство. Чтобы избежать этого, установите значение 0 — высота будет динамической.

3. Замените содержимое `NotificationViewController.swift`:

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
> Если вы используйте CocoaPods или Swift Package Manager, импорт должен выглядеть так:  `import SendsaySDK_Notifications`.

> 📘
>
> Обратитесь к [ExampleNotificationContent](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/tree/main/SendsaySDK/ExampleNotificationContent) в [примере приложения](example-app.md) для эталонной реализации.