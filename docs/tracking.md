# Отслеживание

Вы можете передавать данные и события в CDP Sendsay, чтобы лучше понимать поведение клиентов в мобильном приложении.

По умолчанию SDK автоматически отслеживает ряд базовых событий, включая:

* установку приложения (после первой установки и после вызова [anonymize](#anonymize)).
* начало и окончание пользовательской сессии.

Помимо автоматического трекинга вы можете отправлять собственные события, связанные с вашими бизнес-процессами.

## События

### Отслеживание пользовательских событий

Для отслеживания пользовательских событий используйте метод `trackEvent()`.

Вы можете использовать любое удобное и описательное название события.

#### Аргументы

| Название                  | Тип                       | Описание |
| ------------------------- | ------------------------- | ----------- |
| properties                | [String: JSONConvertible] | Словарь свойств события. |
| eventType **(обязательный)**  | String                    | Тип события, например, `screen_view`. |

#### SSEC (События модуля «Продажи»)

Подробное описание доступно в документации: [События модуля «Продажи»](https://docs.sendsay.ru/ecom/how-to-configure-data-transfer).

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

#### Пример 1. Отслеживание просмотра экрана

Предположим, вам нужно понимать, какие экраны приложения чаще всего просматривают пользователи. Для этого можно отправлять событие `screen_view` и передавать название экрана в свойстве `screen_name`.

Сначала создайте словарь с нужными свойствами:
```swift
let properties: [String: JSONValue] = [
    "screen_name": "dashboard",
    "other_property": 123.45
]
let eventType = "screen_view"

properties["cce"] = .string(jsonString)

```

Затем передайте данные в `trackEvent()`:

```swift
Sendsay.shared.trackEvent(
    properties: properties,
    timestamp: nil,
    eventType: eventType
)
```

##### Пример 2. Сложные свойства с вложенным JSON

Если вы хотите отправить более детализированное событие — например, результат покупки, список товаров и итоговую стоимость — можно использовать вложенную структуру в параметре `properties`:

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
Это событие позволит анализировать успешные покупки, состав корзины и сумму заказа.

## Клиенты

Без идентификации SDK связывает события с анонимным клиентом через автоматически сгенерированный cookie.

После идентификации клиента (по email, телефону, csid и т. д.) события будут связаны с этим идентификатором.

### Идентификация

Используйте метод `identifyCustomer()` для передачи уникальных идентификаторов клиента (email, телефон, csid) и, при необходимости, дополнительных свойств (имя, возраст и др.).

> ❗️
>
> SDK сохраняет данные клиента в локальном кэше. Чтобы очистить кэш, используйте [anonymize](#anonymize).
> Если профиль клиента был удалён из CDP Sendsay, то при следующей инициализации SDK может заново создать профиль по локальным данным.

#### Аргументы

| Название                    | Тип                       | Описание |
| --------------------------- | ------------------------- | ----------- |
| customerIds **(обязательный)**  | [String: String]          | Словарь уникальных идентификаторов клиента. Принимаются только идентификаторы, определенные в проекте Engagement. |
| properties                  | [String: JSONConvertible] | Словарь свойств клиента. |

#### Передача данных в профиль клиента (member.set)

Подробное описание доступно в документации: [Метод member.set SendsayAPI](https://sendsay.ru/api/api.html#%D0%A1%D0%BE%D0%B7%D0%B4%D0%B0%D1%82%D1%8C-%D0%BF%D0%BE%D0%B4%D0%BF%D0%B8%D1%81%D1%87%D0%B8%D0%BA%D0%B0-%D0%9E%D0%B1%D0%BD%D0%BE%D0%B2%D0%B8%D1%82%D1%8C-%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D0%B5-%D0%BF%D0%BE%D0%B4%D0%BF%D0%B8%D1%81%D1%87%D0%B8%D0%BA%D0%B0-%D0%9A%D0%94).

#### Примеры

В примере создаются два словаря — с основным индентификатором и дополнительными свойствами клиента:

```swift
let customerIds: [String: JSONConvertible] = [
    "registered": "jane.doe@example.com"
]
```
```swift
let properties: [String: JSONConvertible] = [
    "first_name": "Jane",
    "last_name": "Doe",
    "age": 32 
]
```

Созданные словари нужно передать в `identifyCustomer()`:

```swift
Sendsay.identifyCustomer(customerIds: customerIds,
    properties: properties,
    timestamp: nil)
```

Если вы хотите обновить идентификатор клиента без дополнительных свойств, передайте пустой словарь для `properties`:

```swift
Sendsay.identifyCustomer(customerIds: customerIds,
    properties: [:],
    timestamp: nil)
```


### Анонимизация

Используйте `anonymize()` при выходе пользователя из приложения или когда нужно сбросить локальное состояние SDK, например, когда пользователь выходит из приложения.

Вызов `anonymize()` приведёт к тому, что SDK:

* удалит push-токен из локального хранилища устройства и профиля клиента в CDP Sendsay;
* очистит локальные репозитории и кэши (кроме уже отслеженных событий);
* отследит новое начало сессии, если включён `automaticSessionTracking`;
* создаст новую запись клиента в Sendsay (генерируется новый `cookie`);
* назначит предыдущий push-токен новой записи клиента;
* отследит новое событие `installation`.