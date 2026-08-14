---
title: Push-уведомления
excerpt: Включение push-уведомлений в вашем приложении с помощью iOS SDK
slug: ios-sdk-push-notifications
categorySlug: integrations
parentDocSlug: ios-sdk
---

С помощью CDP Sendsay вы можете отправлять push-уведомления пользователям вашего приложения через [сегменты](https://docs.sendsay.ru/subscribers/lists-and-segments/what-is-segment/#%D0%BA%D0%B0%D0%BA-%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D1%82%D1%8C-%D1%81%D0%B5%D0%B3%D0%BC%D0%B5%D0%BD%D1%82), в том числе через [редактор сценариев/автоматизацию рассылок](https://docs.sendsay.ru/automations/automation-with-workflows/workflow-blocks/#%D0%BC%D1%83%D0%BB%D1%8C%D1%82%D0%B8%D0%BA%D0%B0%D0%BD%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B5-%D1%81%D1%86%D0%B5%D0%BD%D0%B0%D1%80%D0%B8%D0%B8). SDK обрабатывает полученные сообщения и отображает уведомления на устройстве.

Push-уведомления могут быть видимыми или тихими — для фоновых задач и обновления данных.

> 📘
>
> Узнать, как создавать push-уведомления, можно в разделах [Мобильные push-уведомления](https://docs.sendsay.ru/other-channels/mobile-push/how-to-create-mobile-push-campaign) документации CDP Sendsay.

> ❗️ Устаревание автоматическиой регистрации push
>
> Предыдущие версии SDK использовали method swizzling для автоматической регистрации push-уведомлений, что вызывало конфликты. Сейчас автоматическая регистрация не используется. 
Иногда это вызывало проблемы и поэтому больше не поддерживается. Реализуйте методы делегата вручную — [Метододы делегата приложения](#шаг-3-методы-делегата-приложения).

## Требования

Чтобы отправлять push-уведомления из CDP Sendsay:

- получите ключ Apple Push Notification service (APNs).
- Настройте интеграцию APNs в веб-приложении CDP Sendsay.

> 📘
>
> [Настройка Apple Push Notification Service](https://docs.sendsay.ru/other-channels/mobile-push/how-to-connect-mobile-push#%D0%BF%D0%B0%D1%80%D0%B0%D0%BC%D0%B5%D1%82%D1%80%D1%8B-%D0%BF%D0%BE%D0%B4%D0%BA%D0%BB%D1%8E%D1%87%D0%B5%D0%BD%D0%B8%D1%8F).

## Интеграция

Ниже описаны минимальные необходимые настройки для включения push-уведомлений в вашем приложении.

### Шаг 1: Включение возможностей push

В Xcode откройте **Signing & Capabilities** для таргета приложения и включите:

- **Push Notifications** — для push-уведомлений с предупреждениями.
- **Background Modes** > **Remote notifications** — для тихих push-уведомлений.
- **App Groups** — для работы расширений уведомлений. Создайте новую группу приложений для вашего приложения.

> ❗️
>
> Для включения `Push Notifications` нужна платная учётная запись разработчика Apple.


### Шаг 2: Настройка SDK

[Настройте](../docs/configuration.md) SDK с `pushNotificationTracking: .enabled(appGroup:)` для включения push-уведомлений. Используйте группу приложений, которую вы создали на предыдущем шаге.

``` swift
Sendsay.shared.configure(
    Sendsay.projectSettings(...),
    pushNotificationTracking: .enabled(appGroup: "YOUR_APP_GROUP")
)
```
[в разработке] SDK поддерживает самопроверку настройки push: она отследит push-токен и запросит у CDP Sendsay отправку тихого пуша на устройство, для подтверждения его готовности принимать уведомления.

 ``` swift
 Sendsay.shared.checkPushSetup = true
 ``` 
Установите флаг **до** [инициализации SDK](setup.md#инициализация-sdk).

### Шаг 3: Методы делегата приложения

Чтобы приложение могло отвечать на события, связанные с push-уведомлениями, оно должно иметь три метода делегата:

- `application:didRegisterForRemoteNotificationsWithDeviceToken:` — вызывается, когда ваше приложение регистрируется для push-уведомлений.
- `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` — вызывается, когда тихий пуш или пуш с предупреждением поступает, пока приложение находится на переднем плане.
- `userNotificationCenter(_:didReceive:withCompletionHandler:)`— вызывается, когда пользователь открывает пуш с предупреждением.

SDK предоставляет готовую реализацию в классе [**SendsayAppDelegate**](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/SendsaySDK/Classes/SendsayAppDelegate.swift). Рекомендуем расширить `SendsayAppDelegate` в вашем `AppDelegate`. 

Для приложений, использующих жизненный цикл UIKit, убедитесь, что класс `AppDelegate` наследует `SendsayAppDelegate`:

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

Для приложений, использующих жизненный цикл SwiftUI, зарегистрируйте `UIApplicationDelegateAdaptor`, ссылающийся на `AppDelegate`, который наследует `SendsayAppDelegate`:

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

Если вы не хотите или не можете расширить `SendsayAppDelegate`, можете использовать его в качестве справочника для самостоятельной реализации трех методов делегата.

#### Контрольный список для проверки настройки методов делегата

Убедитесь, что:

 - [ ] Ваш метод делегата `application:didRegisterForRemoteNotificationsWithDeviceToken:` вызывает `Sendsay.shared.handlePushNotificationToken`.
 - [ ] Ваши методы `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` и `userNotificationCenter(_:didReceive:withCompletionHandler:)` вызывают `Sendsay.shared.handlePushNotificationOpened`
 - [ ] Вы вызываете `UNUserNotificationCenter.current().delegate = self`
 - [ ] Самопроверка получает токен при запуске приложения.

### Шаг 4: Регистрация для получения push-уведомлений

Для получения видимых уведомлений требуется разрешение пользователя: 

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
[Тихие пуши](#тихие-push-уведомления) не требуют разрешения.

Если пользователь ещё не предоставил разрешение, этот код запустит предупреждение, просящее пользователя разрешить push-уведомления. Если пользователь ранее предоставил разрешение, свойство `granted` будет `true`, и код напрямую выполнит замыкание и зарегистрирует приложение для получения уведомлений.

По умолчанию SDK отслеживает push-токен только в том случае, если приложение авторизовано (если не включена [проверка настройки push](#шаг-2-настройка-sdk)). Как отслеживать токен даже когда приложение не авторизовано читайте в разделе [Тихие Push-уведомления](#тихие-push-уведомления).

#### Контрольный список для проверки регистрации разрешения пользователя

 - [ ] CDP Sendsay теперь должен иметь возможность отправлять push-уведомления на ваше устройство. Подробнее: [Создание нового уведомления](https://docs.sendsay.ru/other-channels/mobile-push/how-to-create-mobile-push-campaign/) в документации CDP Sendsay.

## Настройки и дополнительные возможности

### Обработка полученных уведомлений

Чтобы приложение корректно реагировало на входящие push-уведомления, укажите делегата, который будет вызываться при открытии уведомления пользователем или при получении [тихое push-уведомление](#тихие-push-уведомления).

Делегат должен реализовать протокол `PushNotificationManagerDelegate` и метод `pushNotificationOpened`, которому SDK передаст выбранное пользователем действие и [полезную нагрузку уведомления](#пример-полезной-нагрузки). При необходимости вы также можете реализовать метод `silentPushNotificationReceived` для обработки тихих push-уведомлений.

Назначить делегата можно двумя способами: 
- напрямую через свойство `Sendsay.shared.pushNotificationsDelegate`,
- указав параметр `delegate` в `pushNotificationTracking: .enabled`.


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
> Обратитесь к [`AppDelegate`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/AppDelegate.swift) в [примере приложения](example-app.md) для базового примера.

### Тихие push-уведомления

Тихие push-уведомления не отображаются и не воспроизводят звук, но пробуждают приложение, чтобы оно могло выполнить фоновую задачу.

Для получения push-уведомлений приложение должно отследить push-токен в бэкенд CDP Sendsay. SDK делает это автоматически, если включено отслеживание push-уведомлений и реализованы все необходимые методы делегатов, и приложение [авторизовано](#шаг-4-регистрация-для-получения-push-уведомлений) получать обычные (видимые) пуши с предупреждениями.

Тихие push-уведомления сами по себе не требуют авторизации пользователя. Если вы хотите отслеживать push-токен даже при отсутствии разрешения на отображение уведомлений, установите параметр `requirePushAuthorization` в значение `false`. В этом режиме SDK будет регистрироваться для push-уведомлений и отправлять токен при каждом запуске приложения.

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

Для ответа на тихие уведомления установите `Sendsay.shared.pushNotificationsDelegate` и реализуйте метод `silentPushNotificationReceived`. Подробнее — в разделе [Обработка полученных push-уведомлений](#обработка-полученных-уведомлений).

> 👍
>
> Тихие push-уведомления требуют возможностей `Background Modes` и `Remote notifications`.

> ❗️
>
> [Официальная документация Apple](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app) утверждает, что вы не должны пытаться отправлять более двух или трех уведомлений в час.

### Богатые push-уведомления

Богатые push-уведомления могут содержать изображения, кнопки действий и аудио. Чтобы включить эту функциональность, добавьте в проект два расширения приложения: **Notification Service Extension** и **Notification Content Extension**.

Настройте каждое расширение по инструкции в разделе [Расширения уведомлений](https://documentation.bloomreach.com/engagement/docs/ios-sdk-notification-extensions). Это позволит использовать службу `SendsayNotificationService`, входящую в SDK.

Метод `SendsayNotificationContentService.didReceive()` улучшает содержимое уведомления, добавляя изображение и действия, переданные в полезной нагрузке `UNNotification`. Все показанные действия автоматически регистрируются с нужной конфигурацией: SDK обеспечит корректное открытие приложения с переданными данными и обработает клики по кампаниям.

#### Контрольный список для проверки богатых push-уведомлений
 - [ ] Убедитесь, что push-уведомления с изображениями и кнопками, отправленные из CDP Sendsay, корректно отображаются на устройстве.  Отслеживание доставки push должно работать.
 - [ ] Если кнопки не появляются в развёрнутом уведомлении, значит, расширение контента не применяется. Проверьте значение `UNNotificationExtensionCategory` в `Info.plist` (оно должно быть внутри `NSExtensionAttributes`) и убедитесь, что `iOS Deployment Target` совпадает у расширений и у основного приложения.

### Звук предупреждения push-уведомления

> 👍
>
> Для использования звуков вам нужно реализовать [богатые push-уведомления](#богатые-push-уведомления).

Push-уведомления, которые проходят через `SendsayNotificationService.process()`, могут воспроизводить стандартный звук или ваш собственный звуковой файл.

Чтобы использовать стандартный звук, укажите значение `default` в поле **Media** > **Sound** в сценарии push-уведомления в веб-приложении CDP Sendsay.

![Настройка звука для push-уведомления в CDP Sendsay](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-ios/main/docs/img/push-sound-config.png)

Чтобы использовать настраиваемый звук:
1. Создайте звуковой файл в формате, который [поддерживает iOS](https://developer.apple.com/documentation/usernotifications/unnotificationsound#2943048). 
2. Добавьте его в ваш проект Xcode и добавьте его к таргету приложения.
3. В сценарии push-уведомления укажите имя файла (с учётом регистра, **без расширения**) в поле **Media** > **Sound**.

### Отслеживание доставленных уведомлений

Чтобы отслеживать доставку push-уведомлений, добавьте **Notification Service Extension**, как описано в разделе о [богатых push-уведомлениях](#богатые-push-уведомления).

Когда расширение вызывает `SendsayNotificationService.process` внутри метода `didReceive`, SDK автоматически зафиксирует доставку уведомления как событие `campaign` в CDP Sendsay.

### Получение токена push-уведомления вручную

Иногда приложению требуется получить актуальный push-токен во время работы. Для этого используйте метод `Sendsay.shared.trackPushToken`. Подробнее — в разделе [Отслеживание](tracking.md#отслеживание-сеанса-вручную) документации CDP Sendsay.

> ❗️
>
> После вызова `Sendsay.shared.anonymize()` вручную отслеживать push-токен не нужно: SDK автоматически передаст токен новому анонимному профилю, и приложение продолжит получать push-уведомления.
>
> При последующей идентификации пользователя через `Sendsay.shared.identifyCustomer` всегда используйте [hard ID](tracking.md#идентификация). Использование soft ID может привести к тому, что токен push-уведомления будет ошибочно связан с неправильным клиентским профилем.

### Показ уведомлений на переднем плане

По умолчанию, если iOS-приложение получает уведомление, пока находится на переднем плане, баннер не отображается.

В iOS 10 и новее вы можете изменить это поведение, реализовав `UNUserNotificationCenterDelegate` и явно указав системе показывать баннер.

1. Создайте класс, который реализует `UNUserNotificationCenterDelegate`.
2. Переопределите `userNotificationCenter(center:willPresentNotification:withCompletionHandler)` и передайте в обработчик завершения хотя бы тип `alert`.
3. Назначьте этот класс делегатом по умолчанию для `UNUserNotificationCenter`.

> 📘
>
> Пример реализации: https://sarunw.com/posts/notification-in-foreground/.

## Продвинутые случаи использования

### Несколько источников push-уведомлений

SDK обрабатывает только push-уведомления, отправленные с платформы CDP Sendsay. Если ваше приложение получает уведомления из нескольких источников, часть логики обработки вам потребуется реализовать самостоятельно.

#### Условная обработка

[Методы делегата приложения](#шаг-3-методы-делегата-приложения), описанные выше, обеспечивают корректную обработку push-уведомлений, отправленных из CDP Sendsay. 

Чтобы определить, к какому источнику относится входящее уведомление, используйте метод `Sendsay.isSendsayNotification(userInfo:)`. Если метод возвращает `true`, можно передать уведомление SDK. Если уведомление не является уведомлением CDP Sendsay, обработайте его с помощью собственных механизмов или логики другой платформы.

#### Ручное отслеживание
Вы можете полностью отключить встроенное отслеживание push-уведомлений и отслеживать события вручную, используя методы `Sendsay.shared.trackPushToken` и `Sendsay.shared.trackPushOpened`. 

Метод `trackPushOpened` принимает полезную нагрузку в [формате CDP Sendsay](#пример-полезной-нагрузки). При необходимости вы также можете отправлять события `campaign` вручную для уведомлений с любым другим форматом полезной нагрузки.

> ❗️
>
> На работу методов `trackPushReceived` и `trackClickedPush` влияет функция согласия на отслеживание. Если она включена, SDK учитывает требование явного согласия пользователя. Подробнее — в разделе [Согласие на отслеживание](tracking-consent.md) документации CDP Sendsay.

### Настраиваемые действия уведомлений в iOS 11 и ниже

Чтобы поддержать кнопки действий в iOS 11 и ниже, настроенные в веб-приложении CDP Sendsay, необходимо вручную создать категории уведомлений. Эти категории используются для подключения доступных действий и заголовков кнопок.

SDK предоставляет фабричный метод, который упрощает создание таких категорий.

> ❗️
>
> Идентификатор категории, указанный в коде, **должен точно совпадать** с идентификатором, указанным в веб-приложении CDP Sendsay. Несовпадение приведёт к тому, что кнопки действий не будут отображаться.

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

Xcode 12+ поддерживает получение удалённых push-уведомлений в iOS Simulator. Поведение симулятора аналогично работе на реальном устройстве: вы можете запускать сценарии получения уведомлений и тестировать логику обработки.

Токен push-уведомлений (APNs или FCM, если используется Firebase) будет доступен в соответствующих методах делегата приложения, например:

```swift
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) // Native
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) // Firebase
```