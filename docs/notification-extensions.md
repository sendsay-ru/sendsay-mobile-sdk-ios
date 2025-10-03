---
title: Расширения уведомлений
excerpt: Настройка расширений приложения, необходимых для определенных функций push-уведомлений в iOS SDK.
slug: ios-sdk-notification-extensions
categorySlug: integrations
parentDocSlug: ios-sdk-push-notifications
---

Чтобы включить определенные функции уведомлений, поддерживаемые iOS SDK, вы должны добавить одно или оба следующих расширения в ваше приложение:

- [Расширение сервиса уведомлений](https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension) — этот тип расширения позволяет настроить содержимое push-уведомления до его отображения пользователю.
- [Расширение контента уведомлений](https://developer.apple.com/documentation/usernotificationsui/unnotificationcontentextension) - этот тип расширения позволяет настроить способ представления push-уведомления пользователю.

Оба типа расширений требуют Sendsay Notification Service, включенного в SDK.

Эта страница описывает шаги для создания расширения любого типа. Убедитесь, что следуете шагам для каждого расширения.

## Шаг 1: Создание расширения

Перейдите в `File` > `New` > `Target` в Xcode и выберите тип расширения (`Notification Service Extension` или `Notification Content Extension`).

![Создание нового расширения уведомлений в Xcode](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/extension1.png)

> ❗️
>
> Убедитесь, что `iOS Deployment Target` вашего расширения такой же, как для основного приложения.

## Шаг 2: Настройка зависимости SendsaySDK-Notifications

Оба типа расширений требуют зависимость от `SendsaySDK-Notification`, чтобы они могли импортировать `SendsayNotificationService`.

Следуйте инструкциям в соответствующем разделе для менеджера зависимостей, который вы используете.

### CocoaPods

1. Добавьте следующее в `Podfile` в корневой папке вашего проекта Xcode:
   ```
   target 'YourAppExtensionTarget' do
     pod 'SendsaySDK-Notifications'
   end
   ```
   (Замените `YourAppExtensionTarget` на имя цели расширения вашего приложения)
2. В окне терминала перейдите в папку проекта Xcode и выполните следующую команду:
   ```
   pod install
   ```
3. Повторно откройте файл `HelloWorld.xcworkspace`, расположенный в папке вашего проекта, в XCode.

При желании вы можете указать версию SendsaySDK следующим образом, чтобы позволить `pod` автоматически получать любые обновления меньше минорной версии:
```
pod "SendsaySDK-Notifications", "~> 3.6.0"
```

### Swift Package Manager

1. В вашем проекте Xcode перейдите к настройкам цели расширения приложения.
2. На вкладке `General`, в разделе `Frameworks, Libraries, and Embedded Content`, нажмите на `+` и добавьте `SendsaySDK-Notifications`.

## Шаг 3: Реализация расширения

#### Расширение сервиса уведомлений

Этот тип расширения позволяет настроить содержимое push-уведомления до его отображения пользователю.

Перейдите к цели расширения, и на вкладке `Signing & Capabilities` добавьте возможность `App Groups`, выбрав ту же группу, которую вы использовали для основного приложения.

Откройте `NotificationService.swift` и замените его содержимое кодом ниже, чтобы вызвать методы `SendsayNotificationService` для обработки уведомлений и обработки тайм-аутов.

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
> Если вы управляете зависимостями с помощью CocoaPods или Swift Package Manager, вы должны использовать `import SendsaySDK_Notifications` вместо `import SendsaySDKNotifications` в коде выше.

> 📘
>
> Обратитесь к [ExampleNotificationService](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/tree/main/SendsaySDK/ExampleNotificationService) в [примере приложения](https://documentation.bloomreach.com/engagement/docs/ios-sdk-example-app) для эталонной реализации.

#### Расширение контента уведомлений

Этот тип расширения позволяет настроить способ представления push-уведомления пользователю.

Будет создан файл storyboard по умолчанию, `MainInterface.storyboard`. Удалите его, он вам не понадобится.

Теперь вы измените реализацию контроллера представления по умолчанию.

Расширение сервиса, которое вы создали на предыдущем шаге, изменит `categoryIdentifier` уведомления на `SENDSAY_ACTIONABLE`. Вы должны настроить расширение контента для отображения push-уведомлений с этой категорией.

Откройте `Info.plist` в группе расширения контента.

- Под `NSExtension` > `NSExtensionAttributes`:
  - Установите `UNNotificationExtensionCategory` в `SENDSAY_ACTIONABLE`.
- Под `NSExtension`:
  - Удалите `NSExtensionMainStoryboard`.
  - Добавьте `NSExtensionPrincipalClass` и установите его значение в класс вашего контроллера представления, например, `TestingPushContentExtension.NotificationViewController`.

![Настройка расширения контента уведомлений в Xcode](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/extension3.png)

Обратите внимание на параметр `UNNotificationExtensionInitialContentSizeRatio` (со значением по умолчанию 1). Он указывает соотношение между шириной и высотой контента в push-уведомлении. По умолчанию контент такой же высоты, как и ширины. Эта настройка не является частью SDK, но может вызвать нежелательное пустое пространство, когда изображение отсутствует. Измените это значение на 0, если вы хотите, чтобы высота была динамической (она будет масштабироваться до правильной высоты, если изображение присутствует, но не будет пустого пространства, если его нет).

Откройте `NotificationViewController.swift` и замените его содержимое кодом ниже, чтобы он передавал уведомление в `SendsayNotificationContentService`, который будет отображать богатое уведомление.

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
> Если вы управляете зависимостями с помощью CocoaPods или Swift Package Manager, вы должны использовать `import SendsaySDK_Notifications` вместо `import SendsaySDKNotifications` в коде выше.

> 📘
>
> Обратитесь к [ExampleNotificationContent](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/tree/main/SendsaySDK/ExampleNotificationContent) в [примере приложения](https://documentation.bloomreach.com/engagement/docs/ios-sdk-example-app) для эталонной реализации.