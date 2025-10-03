# Отслеживание

Вы можете передавать данные и события в CDP Sendsay, чтобы узнать больше о ваших клиентах.

По умолчанию SDK автоматически отслеживает определенные события, включая:

* Установку (после установки приложения и после вызова [anonymize](#anonymize))
* Начало и окончание пользовательской сессии

Кроме того, вы можете отслеживать пользовательские события, связанные с вашими бизнес-процессами.

## События

### Отслеживание событий

Используйте метод `trackEvent()` для отслеживания пользовательских событий, связанных с вашими бизнес-процессами.

Вы можете использовать любое имя для типа пользовательского события. Мы рекомендуем использовать описательное и удобочитаемое имя.

#### Аргументы

| Название                  | Тип                       | Описание |
| ------------------------- | ------------------------- | ----------- |
| properties                | [String: JSONConvertible] | Словарь свойств события. |
| eventType **(обязательный)**  | String                    | Название типа события, например `screen_view`. |

#### SSEC (События модуля "Продажи")

Обратитесь к документации [События модуля "Продажи"](https://docs.sendsay.ru/ecom/how-to-configure-data-transfer).

```swift
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
let currentDateTime = Date()

let clearBasketInfo: TrackSSECData?

do {
    // Создание события очистки корзины
    clearBasketInfo = try TrackSSECDataBuilders.basketClear()
    .setProduct(dateTime: dateFormatter.string(from: currentDateTime))
    .setItems([
        OrderItem(id: "-1")
    ])
    .build()

    // Отправка события
    Sendsay.shared.trackEvent(
        properties: clearBasketInfo!.toSsecProps(),
        timestamp: nil,
        eventType: TrackingSSECType.basketClear.rawValue
    )
} catch {
    Sendsay.logger.log(.error, message: "trackClearBasket parse error: \(error)")
}
```

#### CCE (Пользовательские события) (в разработке)

```swift
do {
    let properties: [String: JSONValue] = [:]
    let customJsonString = """{"any-key": "any-value"}""".trimIndent()
    let eventType = "custom_event_name"

    properties["cce"] = .string(jsonString)
    
    /// ......

    // Отправка события
    Sendsay.shared.trackEvent(
        properties: properties, 
        timestamp: nil, 
        eventType: eventType
    )
} catch {
    Sendsay.logger.log(.error, message: "CCE error: \(error)")
}
```


#### Примеры

Представьте, что вы хотите отслеживать, какие экраны просматривает клиент. Вы можете создать настраиваемое событие `screen_view` для этого.

Сначала создайте словарь со свойствами, которые вы хотите отслеживать с этим событием. В нашем примере вы хотите отслеживать название экрана, поэтому включите свойство `screen_name` вместе с любыми другими релевантными свойствами:

```swift
let properties: [String: JSONValue] = [
    "screen_name": "dashboard",
    "other_property": 123.45
]
let eventType = "screen_view"

properties["cce"] = .string(jsonString)

```

Передайте словарь в `trackEvent()` вместе с `eventType` (`screen_view`) следующим образом:

```swift
Sendsay.shared.trackEvent(
    properties: properties,
    timestamp: nil,
    eventType: eventType
)
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
Sendsay.shared.trackEvent(
    properties: properties,
    timestamp: nil,
    eventType: "purchase"
)
```

## Клиенты

Без дополнительной идентификации события отслеживаются для анонимного клиента, определяемого только по т.н. cookie (автоматически сгенеренный идентификтор). Когда клиент идентифицируется по собственному идентификатору (email, телефон, csid), события будут ассоциированы с переданным основным идентификатором.

### Идентификация

Используйте метод `identifyCustomer()` для идентификации клиента по его уникальному для ваших бизнес-процессов идентификатору (email, телефон, csid).

По умолчанию используется ключ `registered`, и его значение – это обычно адрес электронной почты клиента. Однако ваши настройки мобильного приложения могут определять другой основной идентификатор.

По желанию вы можете передавать в CDP Sendsay дополнительные свойства клиента, такие как имя и фамилия, возраст и т.д.

> ❗️
>
> SDK сохраняет данные клиента, включая идентификаторы, переданные через `identifyCustomer()`, в локальном кэше на устройстве. Очистка локального кэша требует вызова [anonymize](#anonymize).
> Если профиль клиента удален из базы данных CDP Sendsay, последующая инициализация SDK в приложении может привести к повторному созданию профиля клиента из локально кэшированных данных.

#### Аргументы

| Название                    | Тип                       | Описание |
| --------------------------- | ------------------------- | ----------- |
| customerIds **(обязательный)**  | [String: String]          | Словарь уникальных идентификаторов клиента. Принимаются только идентификаторы, определенные в проекте Engagement. |
| properties                  | [String: JSONConvertible] | Словарь свойств клиента. |

#### Передача данных в профиль клиента (member.set)

Обратитесь к документации [метода member.set SendsayAPI](https://sendsay.ru/api/api.html#%D0%A1%D0%BE%D0%B7%D0%B4%D0%B0%D1%82%D1%8C-%D0%BF%D0%BE%D0%B4%D0%BF%D0%B8%D1%81%D1%87%D0%B8%D0%BA%D0%B0-%D0%9E%D0%B1%D0%BD%D0%BE%D0%B2%D0%B8%D1%82%D1%8C-%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B5-%D0%BF%D0%BE%D0%B4%D0%BF%D0%B8%D1%81%D1%87%D0%B8%D0%BA%D0%B0-%D0%9A%D0%94).

#### Примеры

Сначала создайте словарь, содержащий как минимум один идентификтор клиента:

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


### Анонимизация

Используйте метод `anonymize()` для удаления всей информации, сохраненной локально, и сброса текущего состояния SDK. Типичный случай использования - когда пользователь выходит из приложения.

Вызов этого метода приведет к тому, что SDK:

* Удалит токен push-уведомлений для текущего клиента из локального хранилища устройства и профиля клиента в CDP Sendsay.
* Очистит локальные репозитории и кэши, исключая отслеженные события.
* Отследит новое начало сессии, если включен `automaticSessionTracking`.
* Создаст новую запись клиента в Sendsay (генерируется новый `cookie`).
* Назначит предыдущий токен push-уведомлений новой записи клиента.
* Отследит новое событие `installation` для нового клиента.