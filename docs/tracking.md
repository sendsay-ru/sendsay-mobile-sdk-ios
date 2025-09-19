---
title: Отслеживание
excerpt: Отслеживание клиентов и событий с помощью iOS SDK
slug: ios-sdk-tracking
categorySlug: integrations
parentDocSlug: ios-sdk
---

Вы можете отслеживать события в Engagement, чтобы узнать больше о моделях использования вашего приложения и сегментировать клиентов по их взаимодействиям.

По умолчанию SDK отслеживает определенные события автоматически, включая:

* Установку (после установки приложения и после вызова [anonymize](#anonymize))
* Начало и окончание пользовательской сессии
* Событие баннера для показа внутриприложенческого сообщения или блока контента

Дополнительно вы можете отслеживать любые настраиваемые события, релевантные для вашего бизнеса.

> 📘
>
> Также см. [FAQ по отслеживанию мобильного SDK](https://support.bloomreach.com/hc/en-us/articles/18153058904733-Mobile-SDK-tracking-FAQ) в Центре поддержки Bloomreach.

> ❗️ Защитите конфиденциальность ваших клиентов

 > Убедитесь, что вы получили и сохранили согласие на отслеживание от вашего клиента перед инициализацией Sendsay iOS SDK.
 > 
 > Чтобы убедиться, что вы не отслеживаете события без согласия клиента, вы можете использовать `Sendsay.shared.clearLocalCustomerData(appGroup: String)`, когда клиент отказывается от отслеживания (это применимо к новым пользователям или возвращающимся клиентам, которые ранее отказались). Это приведет SDK в состояние, как если бы он никогда не был инициализирован. Эта опция также предотвращает повторное использование существующих cookies для возвращающихся клиентов.
 > 
 > Обратитесь к [Очистка локальных данных клиента](#clear-local-customer-data) для получения подробностей.
 > 
 > Если клиент отказал в согласии на отслеживание после инициализации Sendsay iOS SDK, вы можете использовать `Sendsay.shared.stopIntegration()` для остановки интеграции SDK и удаления всех локально сохраненных данных.
 >
 > Обратитесь к [Остановка интеграции SDK](#stop-sdk-integration) для получения подробностей.

## События

### Отслеживание события

Используйте метод `trackEvent()` для отслеживания любого настраиваемого типа события, релевантного для вашего бизнеса.

Вы можете использовать любое имя для настраиваемого типа события. Мы рекомендуем использовать описательное и читаемое имя.

Обратитесь к документации [Настраиваемые события](https://documentation.bloomreach.com/engagement/docs/custom-events) для обзора часто используемых настраиваемых событий.

#### Аргументы

| Название                  | Тип                       | Описание |
| ------------------------- | ------------------------- | ----------- |
| properties                | [String: JSONConvertible] | Словарь свойств события. |
| timestamp                 | Double                    | Unix timestamp, указывающий, когда событие было отслежено. Укажите значение `nil` для использования текущего времени. |
| eventType **(обязательный)**  | String                    | Название типа события, например `screen_view`. |

#### Примеры

Представьте, что вы хотите отслеживать, какие экраны просматривает клиент. Вы можете создать настраиваемое событие `screen_view` для этого.

Сначала создайте словарь со свойствами, которые вы хотите отслеживать с этим событием. В нашем примере вы хотите отслеживать название экрана, поэтому включите свойство `screen_name` вместе с любыми другими релевантными свойствами:

```swift
let properties: [String: JSONConvertible] = [
    "screen_name": "dashboard", 
    "other_property": 123.45
]
```

Передайте словарь в `trackEvent()` вместе с `eventType` (`screen_view`) следующим образом:

```swift
Sendsay.shared.trackEvent(properties: properties, 
    timestamp: nil, 
    eventType: "screen_view")
```

Второй пример ниже показывает, как вы можете использовать вложенную JSON структуру для сложных свойств при необходимости:

```swift
let properties: [String: JSONConvertible] = [
    "purchase_status": "success",
    "product_list": [
        ["product_id": "abc123", "quantity": 2],
        ["product_id": "abc456", "quantity": 1]
    ],
    "total_price": 7.99,
]
Sendsay.shared.trackEvent(properties: properties,
        timestamp: nil,
        eventType: "purchase")
```

> 👍
>
> При необходимости вы можете предоставить настраиваемый `timestamp`, если событие произошло в другое время. По умолчанию будет использоваться текущее время.

## Клиенты

[Идентификация ваших клиентов](https://documentation.bloomreach.com/engagement/docs/customer-identification) позволяет отслеживать их на разных устройствах и платформах, улучшая качество данных о клиентах.

Без идентификации события отслеживаются для анонимного клиента, идентифицируемого только по cookie. После идентификации клиента по hard ID эти события будут переданы вновь идентифицированному клиенту.

> 👍
>
> Помните, что, хотя пользователь приложения и запись клиента могут быть связаны soft или hard ID, они являются отдельными сущностями, каждая со своим жизненным циклом. Найдите время подумать о том, как их жизненные циклы связаны и когда использовать [identify](#identify) и [anonymize](#anonymize).

### Идентификация

Используйте метод `identifyCustomer()` для идентификации клиента, используя их уникальный [hard ID](https://documentation.bloomreach.com/engagement/docs/customer-identification#hard-id).

Hard ID по умолчанию - `registered`, и его значение обычно является адресом электронной почты клиента. Однако ваш проект Engagement может определить другой hard ID.

При желании вы можете отслеживать дополнительные свойства клиента, такие как имя и фамилия, возраст и т.д.

> ❗️
>
> Хотя возможно использовать `identifyCustomer` с [soft ID](https://documentation.bloomreach.com/engagement/docs/customer-identification#section-soft-id), разработчики должны быть осторожны при этом. В некоторых случаях (например, после использования `anonymize`) это может непреднамеренно связать текущего пользователя с неправильным профилем клиента.

> ❗️
>
> SDK сохраняет данные, включая hard ID клиента, в локальном кэше на устройстве. Удаление hard ID из локального кэша требует вызова [anonymize](#anonymize) в приложении.
> Если профиль клиента анонимизирован или удален в веб-приложении Bloomreach Engagement, последующая инициализация SDK в приложении может привести к повторной идентификации или воссозданию профиля клиента из локально кэшированных данных.

> Всегда используйте [hard ID](https://documentation.bloomreach.com/engagement/docs/customer-identification#hard-id) для идентификации клиента. Использование soft ID с `identifyCustomer` может непреднамеренно привести к тому, что клиент будет связан с неправильным профилем.

#### Аргументы

| Название                    | Тип                       | Описание |
| --------------------------- | ------------------------- | ----------- |
| customerIds **(обязательный)**  | [String: String]          | Словарь уникальных идентификаторов клиента. Принимаются только идентификаторы, определенные в проекте Engagement. |
| properties                  | [String: JSONConvertible] | Словарь свойств клиента. |
| timestamp                   | Double                    | Unix timestamp, указывающий, когда свойства клиента были обновлены. Укажите значение `nil` для использования текущего времени. |

#### Примеры

Сначала создайте словарь, содержащий как минимум hard ID клиента:

```swift
let customerIds: [String: JSONConvertible] = [
    "registered": "jane.doe@example.com"
]
```

При желании создайте словарь с дополнительными свойствами клиента:

```swift
let properties: [String: JSONConvertible] = [
    "first_name": "Jane",
    "last_name": "Doe",
    "age": 32 
]
```

Передайте словари `customerIds` и `properties` в `identifyCustomer()`:

```swift
Sendsay.identifyCustomer(customerIds: customerIds,
    properties: properties,
    timestamp: nil)
```

Если вы хотите только обновить ID клиента без дополнительных свойств, вы можете передать пустой словарь для `properties`:

```swift
Sendsay.identifyCustomer(customerIds: customerIds,
    properties: [:],
    timestamp: nil)
```

> 👍
>
> При необходимости вы можете предоставить настраиваемый `timestamp`, если идентификация произошла в другое время. По умолчанию будет использоваться текущее время.

### Анонимизация

Используйте метод `anonymize()` для удаления всей информации, сохраненной локально, и сброса текущего состояния SDK. Типичный случай использования - когда пользователь выходит из приложения.

Вызов этого метода заставит SDK:

* Удалить токен push-уведомления для текущего клиента из локального хранилища устройства и профиля клиента в Engagement.
* Очистить локальные репозитории и кэши, исключая отслеженные события.
* Отследить новое начало сессии, если включен `automaticSessionTracking`.
* Создать новую запись клиента в Engagement (генерируется новый `cookie` soft ID).
* Назначить предыдущий токен push-уведомления новой записи клиента.
* Предварительно загрузить внутриприложенческие сообщения, блоки контента в приложении и почтовый ящик приложения для нового клиента.
* Отследить новое событие `installation` для нового клиента.

Вы также можете использовать метод `anonymize` для переключения на другой проект Engagement. SDK будет затем отслеживать события в новой записи клиента в новом проекте, аналогично первой сессии приложения после установки на новом устройстве.

#### Примеры

```swift
Sendsay.shared.anonymize()
```

Переключение на другой проект:

```swift
Sendsay.shared.anonymize(
    sendsayProject: SendsayProject(
        baseUrl: "https://api.sendsay.com",
        projectToken: "YOUR PROJECT TOKEN",
        authorization: .token("YOUR API KEY"),
    ),
    projectMapping: nil
)
```

## Сессии

SDK отслеживает сессии автоматически по умолчанию, создавая два события: `session_start` и `session_end`.

Сессия представляет фактическое время, проведенное в приложении. Она начинается при запуске приложения и заканчивается, когда оно переходит в фон. Если пользователь возвращается в приложение до истечения времени ожидания сессии, приложение продолжит текущую сессию.

Время ожидания сессии по умолчанию составляет 60 секунд. Установите `sessionTimeout` в [конфигурации SDK](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configuration) для указания другого времени ожидания.

### Отслеживание сессии вручную

Чтобы отключить автоматическое отслеживание сессий, установите `automaticSessionTracking` в `false` в [конфигурации SDK](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configuration).

Используйте методы `trackSessionStart()` и `trackSessionEnd()` для ручного отслеживания сессий.

#### Примеры

``` swift
Sendsay.shared.trackSessionStart()
```

> 👍
>
> Поведение по умолчанию для многократного ручного вызова `Sendsay.shared.trackSessionStart()` может контролироваться флагом `manualSessionAutoClose` в `Configuration`, который по умолчанию установлен в `true`. Если предыдущая сессия все еще открыта (т.е. она не была вручную закрыта через `Sendsay.shared.trackSessionEnd()`) до повторного вызова `Sendsay.shared.trackSessionStart()`, SDK автоматически отследит `sessionEnd` для предыдущей сессии, а затем запустит новое событие `sessionStart`. Чтобы предотвратить это поведение, установите флаг `manualSessionAutoClose` в `Configuration` в `false`.

``` swift
Sendsay.shared.trackSessionEnd()
``` 

## Push-уведомления

Если разработчики [интегрируют функциональность push-уведомлений](https://documentation.bloomreach.com/engagement/docs/ios-sdk-push-notifications#integration) в свое приложение, SDK автоматически отслеживает токен push-уведомления по умолчанию.

В [конфигурации SDK](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configuration) вы можете отключить автоматическое отслеживание push-уведомлений, установив булево значение свойства `pushNotificationTracking` в `false`. Тогда разработчик должен вручную отслеживать push-уведомления.

> ❗️
>
> На поведение отслеживания push-уведомлений может влиять функция согласия на отслеживание, которая в включенном режиме требует явного согласия на отслеживание. Обратитесь к [документации по согласию](https://documentation.bloomreach.com/engagement/docs/ios-sdk-tracking-consent) для получения подробностей.

### Отслеживание токена вручную

Используйте метод `trackPushToken()` для ручного отслеживания токена для получения push-уведомлений. Токен назначается текущему залогиненному клиенту (с помощью метода `identifyCustomer`).

Вызов этого метода немедленно отследит push-токен независимо от значения `tokenTrackFrequency` (обратитесь к документации [Конфигурация](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configuration) для подробностей).

Каждый раз, когда приложение становится активным, SDK вызывает `verifyPushStatusAndTrackPushToken` и отслеживает токен.

#### Аргументы

| Название                 | Тип    | Описание |
| ---------------------| ------- | ----------- |
| token **(обязательный)** | String  | Строка, содержащая токен push-уведомления. |

#### Пример 

```swift
Sendsay.shared.trackPushToken("value-of-push-token")
```

> ❗️
>
> Помните о вызове [anonymize](#anonymize) всякий раз, когда пользователь выходит из системы, чтобы обеспечить удаление токена push-уведомления из профиля клиента пользователя. Невыполнение этого может привести к тому, что несколько профилей клиентов будут использовать один и тот же токен, что приведет к дублированию push-уведомлений.

### Отслеживание доставки push-уведомлений вручную

Используйте метод `trackPushReceived()` для ручного отслеживания доставки push-уведомлений.

Вы можете передать либо данные уведомления, либо информацию пользователя в качестве аргумента.

#### Аргументы

| Название                   | Тип                                   | Описание |
| -----------------------| -------------------------------------- | ----------- |
| content **(обязательный)** | [UNNotificationContent](https://developer.apple.com/documentation/usernotifications/unnotificationcontent) | Данные уведомления. |

или:

| Название                    | Тип                 | Описание |
| ------------------------| ---------------------| ----------- |
| userInfo **(обязательный)** | \[AnyHashable: Any\] | Объект информации пользователя из данных уведомления. |


#### Пример

Передача данных уведомления в качестве аргумента:

```swift
func trackPushNotifReceived() {
    let notifContent = UNMutableNotificationContent()
    notifContent.title = "Example title"
    // ... и все что нужно, но только `userInfo` требуется для отслеживания
    notifContent.userInfo = [
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
    Sendsay.shared.trackPushReceived(content: notifContent)
}
```

Передача информации пользователя в качестве аргумента:

```swift
func trackPushNotifReceived() {
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
```

### Отслеживание клика по push-уведомлению вручную

Используйте метод `trackPushOpened()` для ручного отслеживания кликов по push-уведомлениям.

#### Аргументы

| Название                     | Тип                 | Описание |
| -------------------------| ---------------------| ----------- |
| userInfo **(обязательный)**  | \[AnyHashable: Any\] | Объект информации пользователя из данных уведомления. |

#### Пример

```swift
func trackPushNotifClick() {
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
```

## Очистка локальных данных клиента

Ваше приложение всегда должно запрашивать у клиентов согласие на отслеживание использования их приложения. Если клиент соглашается на отслеживание событий на уровне приложения, но не на уровне персональных данных, использования метода `anonymize()` обычно достаточно.

Если клиент не соглашается на какое-либо отслеживание, рекомендуется вообще не инициализировать SDK.

Если клиент просит удалить персонализированные данные, используйте метод `clearLocalCustomerData(appGroup: String)` для удаления всей информации, сохраненной локально, до инициализации SDK.

Клиент также может отозвать все согласие на отслеживание после полной инициализации SDK и включения отслеживания. В этом случае вы можете остановить интеграцию SDK и удалить все локально сохраненные данные, используя метод [stopIntegration](#stop-sdk-integration).

Вызов этого метода заставит SDK:

* Удалить токен push-уведомления для текущего клиента из локального хранилища устройства.
* Очистить локальные репозитории и кэши, включая все ранее отслеженные события, которые еще не были отправлены.
* Очистить всю информацию о начале и окончании сессий.
* Удалить запись клиента, сохраненную локально.
* Очистить любые ранее загруженные внутриприложенческие сообщения, блоки контента в приложении и сообщения почтового ящика приложения.
* Очистить конфигурацию SDK от последней вызванной инициализации.
* Остановить обработку полученных push-уведомлений.
* Остановить отслеживание глубоких ссылок и универсальных ссылок (обработка их вашим приложением не затрагивается).

## Остановка интеграции SDK

❗️ Группа приложений должна быть одинаковой для конфигурации и NotificationServices ❗️
 - иначе полученный push может быть отслежен

Ваше приложение всегда должно запрашивать у клиента согласие на отслеживание использования приложения. Если клиент соглашается на отслеживание событий на уровне приложения, но не на уровне персональных данных, использования метода `anonymize()` обычно достаточно.

Если клиент не соглашается на какое-либо отслеживание до инициализации SDK, рекомендуется вообще не инициализировать SDK. Для случая удаления персонализированных данных до инициализации SDK см. дополнительную информацию об использовании метода [clearLocalCustomerData](#clear-local-customer-data).

Клиент также может отозвать все согласие на отслеживание позже, после полной инициализации SDK и включения отслеживания. В этом случае вы можете остановить интеграцию SDK и удалить все локально сохраненные данные, используя метод `Sendsay.shared.stopIntegration()`.

Используйте метод `stopIntegration()` для удаления всей информации, сохраненной локально, и остановки SDK, если он уже работает.

Вызов этого метода заставит SDK:

* Удалить токен push-уведомления для текущего клиента из локального хранилища устройства.
* Очистить локальные репозитории и кэши, включая все ранее отслеженные события, которые еще не были отправлены.
* Очистить всю информацию о начале и окончании сессий.
* Удалить запись клиента, сохраненную локально.
* Очистить любые внутриприложенческие сообщения, блоки контента в приложении и сообщения почтового ящика приложения, ранее загруженные.
* Очистить конфигурацию SDK от последней вызванной инициализации.
* Остановить обработку полученных push-уведомлений.
* Остановить отслеживание глубоких ссылок и универсальных ссылок (обработка их вашим приложением не затрагивается).

Если SDK уже работает, вызов этого метода также:

* Останавливает и отключает отслеживание начала и окончания сессии, даже если ваше приложение попытается это сделать позже.
* Останавливает и отключает любое отслеживание событий, даже если ваше приложение попытается это сделать позже.
* Останавливает и отключает любую отправку отслеженных событий, даже если ваше приложение попытается это сделать позже.
* Останавливает отображение внутриприложенческих сообщений, блоков контента в приложении и сообщений почтового ящика приложения.
* Уже отображенные сообщения закрываются.
* Пожалуйста, проверьте поведение закрытия, если вы [настроили](https://documentation.bloomreach.com/engagement/docs/ios-sdk-app-inbox#customize-app-inbox) макет UI почтового ящика приложения.

После вызова метода `stopIntegration()` SDK будет игнорировать любые вызовы API методов до тех пор, пока вы снова не [инициализируете SDK](https://documentation.bloomreach.com/engagement/docs/ios-sdk-setup#initialize_the_sdk).

### Случаи использования

Правильное использование метода `stopIntegration()` зависит от случая использования, поэтому рассмотрите все сценарии.

#### Остановка SDK с загрузкой отслеженных данных

SDK кэширует данные (такие как сессии, события и свойства клиентов) во внутренней локальной базе данных и периодически отправляет их в Bloomreach Engagement. Эти данные сохраняются локально, если у устройства нет сети или если вы настроили SDK на их более редкую загрузку.

Вызов метода `stopIntegration()` удалит все эти локально сохраненные данные, которые могут еще не быть загружены. Чтобы избежать потери этих данных, запросите их отправку перед остановкой SDK:

```swift
// SDK инициализирован с отправкой
Sendsay.shared.configure(...)
Sendsay.shared.flushData()
// Остановка интеграции
Sendsay.shared.stopIntegration()
```

#### Остановка SDK и удаление всех отслеженных данных

SDK кэширует данные (такие как сессии, события и свойства клиентов) во внутренней локальной базе данных и периодически отправляет их в приложение Bloomreach Engagement. Если у устройства нет сети или если вы настроили SDK на их более редкую загрузку, эти данные сохраняются локально.

Вы можете столкнуться со случаем использования, когда клиент удаляется с платформы Bloomreach Engagement, и впоследствии вы хотите удалить его и из локального хранилища.

Пожалуйста, не инициализируйте SDK в этом случае. В зависимости от вашей конфигурации, SDK может загрузить сохраненные отслеженные события. Это может привести к воссозданию профиля клиента в Bloomreach Engagement. Сохраненные события могли быть отслежены для этого клиента, и их загрузка приведет к воссозданию профиля клиента на основе назначенных ID клиентов.

Чтобы предотвратить это, вызовите `stopIntegration()` немедленно без инициализации SDK:

```swift
Sendsay.shared.stopIntegration()
```

Это приведет к удалению всех ранее сохраненных данных с устройства. Следующая инициализация SDK будет считаться свежим новым стартом.

#### Остановка уже работающего SDK

Метод `stopIntegration()` может быть вызван в любое время на настроенном и работающем SDK.

Это можно использовать в случае, когда клиент ранее дал согласие на отслеживание, но отозвал его позже. Вы можете свободно вызвать `stopIntegration()` с немедленным эффектом.

```swift
// Пользователь дал вам разрешение на отслеживание
Sendsay.shared.configure(...)

// Позже пользователь решает остановить отслеживание
Sendsay.shared.stopIntegration()
```

Это приводит к тому, что SDK останавливает все внутренние процессы (такие как отслеживание сессий и обработка push-уведомлений) и удаляет все локально сохраненные данные.

Пожалуйста, имейте в виду, что `stopIntegration()` останавливает любое дальнейшее отслеживание и отправку данных. Если вам нужно загрузить отслеженные данные в Bloomreach Engagement, то [отправьте их синхронно](#stop-the-sdk-but-upload-tracked-data) перед остановкой SDK.

#### Клиент отказывается от согласия на отслеживание

Рекомендуется запрашивать у клиента согласие на отслеживание как можно раньше в вашем приложении. Если клиент отказывается от согласия, пожалуйста, вообще не инициализируйте SDK.

❗️ Удаление AppInbox после `stopIntegration()` 
Добавьте обратный вызов к вашему viewController с AppInboxButton

```swift
IntegrationManager.shared.onIntegrationStoppedCallbacks.append { [weak self] in
    self?.appInboxButton.removeFromSuperview()
    self?.view.layoutIfNeeded()
}
```

❗️ Остановка получения push после `stopIntegration()` 
Вы должны переопределить метод в SendsayAppDelegate
```swift
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        super.userNotificationCenter(.....)
        
        // ваш код при необходимости
    }
}
```

Если вы не можете переопределить этот метод и вызвать super, убедитесь, что добавили `if` к вашему методу

```swift
if IntegrationManager.shared.isStopped && Sendsay.isExponeaNotification(userInfo: notification.request.content.userInfo) {
    Sendsay.logger.log(.error, message: "Will present wont finish, SDK is stopping")
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
    completionHandler([])
}
```

## Платежи

SDK автоматически отслеживает внутриприложенческие покупки.

### Отслеживание платежа

Используйте метод `trackPayment()` для ручного отслеживания платежей.

#### Аргументы

| Название                      | Тип                      | Описание |
| ------------------------- | ------------------------- | ----------- |
| properties                | [String: JSONConvertible] | Словарь свойств платежа. |
| timestamp                 | Double                    | Unix timestamp, указывающий, когда событие было отслежено. Укажите значение `nil` для использования текущего времени. |

#### Пример

``` swift
Sendsay.shared.trackPayment(
  properties: [
      "productId": "123", 
      "currency": "USD", 
      "price": 123.45, 
      "quantity": 2
  ]
  timestamp: nil
)
```

## Свойства по умолчанию

Вы можете настроить свойства по умолчанию для отслеживания с каждым событием. Обратите внимание, что значение свойства по умолчанию будет перезаписано, если отслеживаемое событие имеет свойство с тем же ключом.

Обратитесь к `defaultProperties` в документации [Конфигурация](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configuration) для получения подробностей.

После инициализации SDK вы можете изменить свойства по умолчанию, используя метод `Sendsay.shared.defaultProperties()`.