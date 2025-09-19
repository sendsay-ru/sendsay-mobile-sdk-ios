---
title: Push-уведомления
excerpt: Включение push-уведомлений в вашем приложении с помощью iOS SDK
slug: ios-sdk-push-notifications
categorySlug: integrations
parentDocSlug: ios-sdk
---

Engagement позволяет отправлять push-уведомления пользователям вашего приложения с помощью [сценариев](https://documentation.bloomreach.com/engagement/docs/scenarios-1). Мобильное приложение обрабатывает push-сообщение с помощью SDK и отображает уведомление на устройстве клиента.

Push-уведомления также могут быть тихими, используемыми только для обновления интерфейса приложения или запуска фоновых задач.

> 📘
>
> Чтобы узнать, как создавать push-уведомления в веб-приложении Engagement, обратитесь к [Мобильные push-уведомления](https://documentation.bloomreach.com/engagement/docs/mobile-push-notifications#creating-a-new-notification).

> 📘
>
> Также см. [FAQ по мобильным push-уведомлениям](https://support.bloomreach.com/hc/en-us/articles/18152713374877-Mobile-Push-Notifications-FAQ) в Центре поддержки Bloomreach.

> ❗️ Устаревание автоматических push-уведомлений
>
> Предыдущие версии SDK использовали method swizzling для автоматической регистрации push-уведомлений. Иногда это вызывало проблемы и поэтому больше не поддерживается. Обратитесь к [Реализация методов делегата приложения](#implement-application-delegate-methods) ниже для списка методов делегата, которые ваше приложение должно реализовать для правильной обработки push-уведомлений.

## Требования

Чтобы иметь возможность отправлять push-уведомления из Engagement, вы должны:

- Получить ключ подписи токена аутентификации Apple Push Notification service (APNs)
- Добавить и настроить интеграцию Apple Push Notification Service в веб-приложении Engagement

> 📘
>
> Если вы еще не настроили это, следуйте инструкциям в [Настройка Apple Push Notification Service](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configure-apns).

## Интеграция

Этот раздел описывает шаги для добавления минимальной функциональности push-уведомлений (получение уведомлений с предупреждениями) в ваше приложение.

### Шаг 1: Включение возможностей push

Выберите цель вашего приложения в Xcode, и на вкладке `Signing & Capabilities` добавьте следующие возможности:

- `Push Notifications`
   Требуется для push-уведомлений с предупреждениями.
- `Background Modes` (выберите `Remote notifications`)
   Требуется для тихих push-уведомлений.
- `App Groups` (создайте новую группу приложений для вашего приложения)
   Требуется для расширений приложения, которые обрабатывают доставку push-уведомлений и богатый контент.

> ❗️
>
> Учетная запись разработчика Apple с платным членством должна добавить возможность `Push Notifications`.


### Шаг 2: Настройка SDK

[Настройте](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configuration) SDK с `pushNotificationTracking: .enabled(appGroup:)` для включения push-уведомлений. Используйте группу приложений, которую вы создали на предыдущем шаге.

``` swift
Sendsay.shared.configure(
    Sendsay.projectSettings(...),
    pushNotificationTracking: .enabled(appGroup: "YOUR_APP_GROUP")
)
```

> 👍
>
> SDK предоставляет функцию самопроверки настройки push, чтобы помочь разработчикам успешно настроить push-уведомления. Самопроверка попытается отследить push-токен, запросить у бэкенда Engagement отправить тихий push на устройство и проверить, готово ли приложение открывать push-уведомления.
>
> Чтобы включить проверку настройки, установите `Sendsay.shared.checkPushSetup = true` **до** [инициализации SDK](https://documentation.bloomreach.com/engagement/docs/ios-sdk-setup#initialize-the-sdk):

### Шаг 3: Реализация методов делегата приложения

Чтобы ваше приложение могло отвечать на события, связанные с push-уведомлениями, оно должно иметь три метода делегата:

- `application:didRegisterForRemoteNotificationsWithDeviceToken:`
   Вызывается, когда ваше приложение регистрируется для push-уведомлений.
- `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` 
   Вызывается, когда тихое push-уведомление или push-уведомление с предупреждением поступает, пока ваше приложение находится на переднем плане.
- `userNotificationCenter(_:didReceive:withCompletionHandler:)` 
   Вызывается, когда пользователь открывает push-уведомление с предупреждением.

Класс [`SendsayAppDelegate`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/SendsaySDK/Classes/SendsayAppDelegate.swift) в SDK предоставляет реализации этих методов по умолчанию. Мы рекомендуем вам расширить `SendsayAppDelegate` в вашем `AppDelegate`. 

Для приложений, использующих жизненный цикл UIKit, убедитесь, что ваш класс AppDelegate наследует SendsayAppDelegate:

```swift
@UIApplicationMain
class AppDelegate: SendsayAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // не забудьте вызвать super метод!!
        super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        Sendsay.shared.checkPushSetup = true
        Sendsay.shared.configure(...)
        return true
    }
}
```

Для приложений, использующих жизненный цикл SwiftUI, зарегистрируйте UIApplicationDelegateAdaptor, ссылающийся на AppDelegate, который наследует SendsayAppDelegate.

```swift
// YourApp.swift
@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(YourAppDelegate.self) var appDelegate
    init() {
        // ... инициализация вашего приложения здесь
        // вы можете инициализировать SDK здесь или в реализации AppDelegate
    }
}

// YourAppDelegate.swift
class YourAppDelegate: SendsayAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // не забудьте вызвать super метод!!
        super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        Sendsay.shared.checkPushSetup = true
        Sendsay.shared.configure(...)
        return true
    }
}
```

Если вы не хотите или не можете расширить `SendsayAppDelegate`, вы можете использовать его в качестве справочника для самостоятельной реализации трех методов делегата.

#### Контрольный список

Убедитесь, что:

 - [ ] Ваш метод делегата `application:didRegisterForRemoteNotificationsWithDeviceToken:` вызывает `Sendsay.shared.handlePushNotificationToken`.
 - [ ] Ваши методы `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` и `userNotificationCenter(_:didReceive:withCompletionHandler:)` вызывают `Sendsay.shared.handlePushNotificationOpened`
 - [ ] Вы вызываете `UNUserNotificationCenter.current().delegate = self`
 - [ ] При запуске вашего приложения самопроверка должна иметь возможность получить и отследить токен push-уведомления.

### Шаг 4: Регистрация для получения push-уведомлений

Ваше приложение должно зарегистрироваться для получения push-уведомлений. Важно убедиться, что у вас есть правильная авторизация для получения push-уведомлений. Вам требуется явное разрешение от пользователя для получения "предупреждающих" уведомлений, видимых пользователю. Вам не нужна авторизация для получения [тихих push-уведомлений](#silent-push-notifications) (фоновые обновления).

Вы можете запросить авторизацию и затем зарегистрироваться для получения уведомлений, используя следующий код:

``` swift 
UNUserNotificationCenter.current()
    .requestAuthorization(options: [.badge, .alert, .sound]) { (granted, _) in
        if granted {
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
```

Если пользователь еще не предоставил разрешение, этот код запустит предупреждение, просящее пользователя разрешить push-уведомления. Если пользователь ранее предоставил разрешение, свойство `granted` будет `true`, и код напрямую выполнит замыкание и зарегистрирует приложение для получения уведомлений.

По умолчанию SDK отслеживает токен push-уведомления только в том случае, если приложение авторизовано (если не включена [проверка настройки push](#configure-the-sdk)). Обратитесь к [Тихие Push-уведомления](#silent-push-notifications) ниже, чтобы узнать, как отслеживать push-токен даже когда приложение не авторизовано.

#### Контрольный список: 
 - [ ] Engagement теперь должен иметь возможность отправлять push-уведомления на ваше устройство. Для инструкций обратитесь к руководству [Создание нового уведомления](https://documentation.bloomreach.com/engagement/docs/mobile-push-notifications#creating-a-new-notification).

## Настройка

Этот раздел описывает настройки, которые вы можете реализовать после интеграции минимальной функциональности push-уведомлений.

### Обработка полученных push-уведомлений

Для обработки входящих push-уведомлений вы должны указать делегата, который будет вызываться, когда пользователь открывает push-уведомление или когда получено [тихое push-уведомление](#silent-push-notifications).

Делегат должен реализовать `PushNotificationManagerDelegate` и иметь метод `pushNotificationOpened`. [Полезная нагрузка](#payload-example) уведомления и выбранное пользователем действие передаются в качестве аргументов. По желанию вы также можете реализовать метод `silentPushNotificationReceived` для обработки [тихих push-уведомлений](#silent-push-notifications).

Вы можете установить делегата, установив `Sendsay.shared.pushNotificationsDelegate` напрямую или указав параметр `delegate` в `pushNotificationTracking: .enabled`.


```swift
import SendsaySDK
import UserNotifications

@UIApplicationMain
class AppDelegate: SendsayAppDelegate {

    var window: UIWindow?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        super.application(application, didFinishLaunchingWithOptions: launchOptions)

        Sendsay.shared.configure(
            Sendsay.ProjectSettings(
                // ...
            ),
            pushNotificationTracking: .enabled(
                appGroup: "YOUR APP GROUP",
                delegate: self,
                requirePushAuthorization: false
            )
        )

    }
}

extension AppDelegate: PushNotificationManagerDelegate {
    func pushNotificationOpened(
        with action: SendsayNotificationAction, 
        value: String?, 
        extraData: [AnyHashable : Any]?
    ) {
        // app open, browser, deeplink или none(default)
        print("push action: \(action)")
        // deeplink url, nil для действия открытия приложения
        print("value for action: \(value)") 
        // полезная нагрузка данных, которую вы указали в веб-приложении Sendsay
        print("extra payload specified: \(extraData)")
    }

    // эта функция опциональна
    func silentPushNotificationReceived(extraData: [AnyHashable: Any]?) {
        // полезная нагрузка данных, которую вы указали в веб-приложении Sendsay
        print("extra payload specified: \(extraData)")
    }
}
```

> 📘
>
> Обратитесь к [`AppDelegate`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/AppDelegate.swift) в [примере приложения](https://documentation.bloomreach.com/engagement/docs/ios-sdk-example-app) для базового примера.

### Тихие push-уведомления

Тихие push-уведомления не запускают никаких видимых или звуковых уведомлений на устройстве, но пробуждают приложение, чтобы позволить ему выполнять задачи в фоновом режиме.

Для получения push-уведомлений приложение должно отследить push-токен в бэкенд Engagement. SDK делает это автоматически только в том случае, если отслеживание push-уведомлений включено и правильно реализовано, и приложение [авторизовано](#register-for-receiving-push-notifications) для получения push-уведомлений с предупреждениями.

Тихие push-уведомления не требуют авторизации. Чтобы отслеживать push-токен даже когда приложение не авторизовано, установите переменную конфигурации `requirePushAuthorization` в `false`. Это заставляет SDK регистрироваться для push-уведомлений и отслеживать push-токен при запуске приложения.

``` swift
    Sendsay.shared.configure(
        Sendsay.ProjectSettings(
            projectToken: "YOUR-PROJECT-TOKEN",
            authorization: .token("YOUR-AUTHORIZATION-TOKEN"),
            baseUrl: "YOUR-BASE-URL"
        ),
        pushNotificationTracking: .enabled(
            appGroup: "YOUR-APP-GROUP",
            requirePushAuthorization: false
        )
    )
```

Для ответа на тихие push-уведомления установите `Sendsay.shared.pushNotificationsDelegate` и реализуйте метод `silentPushNotificationReceived`. Обратитесь к [Обработка полученных push-уведомлений](#handle-received-push-notifications) выше для подробностей.

> 👍
>
> Тихие push-уведомления требуют возможностей `Background Modes` и `Remote notifications`.

> ❗️
>
> [Официальная документация Apple](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app) утверждает, что вы не должны пытаться отправлять более двух или трех уведомлений в час.

### Богатые push-уведомления

Богатые push-уведомления могут содержать изображения, кнопки и аудио. Чтобы включить эту функциональность, вы должны добавить два расширения приложения: **Notification Service Extension** и **Notification Content Extension**.

Для каждого расширения следуйте инструкциям в [Расширения уведомлений](https://documentation.bloomreach.com/engagement/docs/ios-sdk-notification-extensions), чтобы правильно настроить его для использования Sendsay Notification Service, включенного в SDK.

Использование метода `SendsayNotificationContentService.didReceive()` улучшит тело уведомления изображением и действиями, доставленными в полезной нагрузке UNNotification. Действия уведомлений, показанные `SendsayNotificationContentService`, регистрируются с конфигурациями для открытия вашего приложения с необходимой информацией и автоматической обработки кликов по кампании.

#### Контрольный список:
 - [ ] Проверьте, что push-уведомления с изображениями и кнопками, отправленные из Engagement, правильно отображаются на вашем устройстве. Отслеживание доставки push должно работать.
 - [ ] Если вы не видите кнопки в развернутом push-уведомлении, расширение контента **не** работает. Дважды проверьте `UNNotificationExtensionCategory` в `Info.plist` - обратите внимание на размещение внутри `NSExtensionAttributes`. Проверьте, что `iOS Deployment Target` одинаков для расширений и основного приложения.

### Звук предупреждения push-уведомления

> 👍
>
> Вы должны реализовать [богатые push-уведомления](#rich-push-notifications) в вашем приложении, чтобы включить звуки предупреждения push-уведомлений.

Полученные push-уведомления, обрабатываемые `SendsayNotificationService.process()`, могут воспроизводить стандартный или настраиваемый звук при отображении уведомления.

Чтобы использовать стандартный звук для уведомления, введите `default` в качестве значения для `Media > Sound` в вашем сценарии push-уведомления в веб-приложении Engagement.
![Настройка звука для push-уведомления в Engagement](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/push-sound-config.png)

Чтобы использовать настраиваемый звук для уведомления, вы должны создать звуковой файл, который [поддерживает iOS](https://developer.apple.com/documentation/usernotifications/unnotificationsound#2943048). Включите звуковой файл в ваш проект Xcode и добавьте его к цели приложения.

После того как настраиваемый звук размещен в вашем приложении, введите имя звукового файла в качестве значения для `Media > Sound` в вашем сценарии push-уведомления в веб-приложении Engagement. Убедитесь, что вы вводите точное имя файла (с учетом регистра) без расширения.

### Отслеживание доставленных уведомлений

Для отслеживания доставки push-уведомлений реализуйте **Notification Service Extension**, как [описано для богатых push-уведомлений выше](#rich-push-notifications).

Вызов `SendsayNotificationService.process` в `didReceive` будет отслеживать доставку уведомления как событие `campaign` в Engagement.

### Получение токена push-уведомления вручную

Иногда вашему приложению может потребоваться получить текущий push-токен во время работы. Вы можете сделать это, используя метод `Sendsay.shared.trackPushToken`. Обратитесь к [Отслеживание](https://documentation.bloomreach.com/engagement/docs/ios-sdk-tracking#track-token-manually) для подробностей.

> ❗️
>
> Обратите внимание, что отслеживание токена push-уведомления вручную не требуется после вызова метода `Sendsay.shared.anonymize()`. В этом случае токен push-уведомления автоматически передается новому анонимному профилю клиента, и приложение продолжит получать push-уведомления.
>
> При последующем вызове `Sendsay.shared.identifyCustomer` всегда используйте [hard ID](https://documentation.bloomreach.com/engagement/docs/customer-identification#hard-id). Использование soft ID может непреднамеренно привести к тому, что токен push-уведомления будет связан с неправильным профилем клиента.

### Показ уведомлений на переднем плане

По умолчанию, если iOS-приложение получает уведомление, пока приложение находится на переднем плане, баннер уведомления не отображается.

В iOS 10 и позже вы можете показывать уведомления на переднем плане, реализовав `UNUserNotificationCenterDelegate` и сказав iOS отображать баннер.

1. Создайте класс, который реализует `UNUserNotificationCenterDelegate`.
2. Переопределите `userNotificationCenter(center:willPresentNotification:withCompletionHandler)` и верните по крайней мере тип alert в его обработчик завершения
3. Установите его как делегат по умолчанию для `UNUserNotificationCenter`.

> 📘
>
> Для примера см. https://sarunw.com/posts/notification-in-foreground/.

## Продвинутые случаи использования

### Несколько источников push-уведомлений

SDK обрабатывает только push-уведомления, отправленные с платформы Engagement. Если вы используете платформы, отличные от Engagement, для отправки push-уведомлений, вы должны реализовать часть логики обработки уведомлений самостоятельно. 

#### Условная обработка

[Реализация методов делегата приложения](#implement-application-delegate-methods) выше описывает методы делегата, необходимые для работы обработки push-уведомлений Engagement. Вы можете использовать метод `Sendsay.isExponeaNotification(userInfo:)` в реализациях делегата для проверки, поступает ли входящее уведомление от Engagement, и если нет, обработать уведомление, используя реализацию для другого источника уведомлений.

#### Ручное отслеживание
Вы можете полностью отключить отслеживание уведомлений и использовать методы `Sendsay.shared.trackPushToken` и `Sendsay.shared.trackPushOpened` для ручного отслеживания событий push-уведомлений. `trackPushOpened` ожидает [формат полезной нагрузки Engagement](#payload-example). Вы всегда можете отследить событие `campaign` вручную для любого формата полезной нагрузки.

> ❗️
>
> На поведение `trackPushReceived` и `trackClickedPush` может влиять функция согласия на отслеживание, которая в включенном режиме учитывает требование явного согласия на отслеживание. Подробнее читайте в документации [согласие на отслеживание](https://documentation.bloomreach.com/engagement/docs/ios-sdk-tracking-consent).

### Настраиваемые действия уведомлений в iOS 11 и ниже

Для поддержки кнопок действий в iOS 11 и ниже, которые можно настроить в веб-приложении Engagement, вы должны реализовать настраиваемые категории уведомлений, которые используются для подключения действий и заголовков кнопок. SDK предоставляет удобный фабричный метод для упрощения создания такой категории.

> ❗️
>
> Идентификатор категории, который вы указываете здесь, должен быть идентичен тому, который вы указываете в бэкенде Engagement.

```swift
// Установка устаревших категорий sendsay
let category1 = UNNotificationCategory(
    identifier: "EXAMPLE_LEGACY_CATEGORY_1",
    actions: [
        SendsayNotificationAction.createNotificationAction(
            type: .openApp, 
            title: "Hardcoded open app", 
            index: 0
        ),
        SendsayNotificationAction.createNotificationAction(
            type: .deeplink, 
            title: "Hardcoded deeplink", 
            index: 1
        )
    ], 
    intentIdentifiers: [], 
    options: []
)
    
UNUserNotificationCenter.current().setNotificationCategories([category1])
```

## Пример полезной нагрузки

```json
{
    "url": "https://example.com/ios",
    "title": "iOS Title",
    "action": "app",
    "message": "iOS Message",
    "image": "https://example.com/image.jpg",
    "actions": [
        {"title": "Action 1", "action": "app", "url": "https://example.com/action1/ios"},
        {"title": "Action 2", "action": "browser", "url": "https://example.com/action2/ios"}
    ],
    "sound": "default",
    "aps": {
        "alert": {"title": "iOS Alert Title", "body": "iOS Alert Body"},
        "mutable-content": 1
    },
    "attributes": {
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
    },
    "url_params": {"param1": "value1", "param2": "value2"},
    "source": "xnpe_platform",
    "silent": false,
    "has_tracking_consent": true,
    "consent_category_tracking": "iOS Consent"
}
```

## Отладка с помощью симулятора iOS

Xcode 12+ поддерживает удаленные push-уведомления с симулятором. Поведение такое же, как с реальным устройством. Вы получите токен для APNs (или FCM для Firebase) из методов делегата приложения. 

```swift
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) // Native
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) // Firebase
```