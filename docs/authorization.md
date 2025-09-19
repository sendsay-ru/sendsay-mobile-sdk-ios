---
title: Авторизация
excerpt: Справочник по режимам авторизации для iOS SDK
slug: ios-sdk-authorization
categorySlug: integrations
parentDocSlug: ios-sdk-setup
---

SDK обменивается данными с Engagement API через авторизованное HTTP/HTTPS соединение. SDK поддерживает два режима авторизации: **авторизация по токену** по умолчанию для доступа к публичному API и более безопасная **авторизация по токену клиента** для доступа к приватному API. Разработчики могут выбрать подходящий режим авторизации для требуемого уровня безопасности.

## Авторизация по токену

Режим авторизации по токену по умолчанию обеспечивает [доступ к публичному API](https://documentation.bloomreach.com/engagement/reference/authentication#public-api-access) с использованием API ключа в качестве токена.

Авторизация по токену используется для следующих API endpoints по умолчанию:

* `POST /track/v2/projects/<projectToken>/customers` для отслеживания данных клиентов
* `POST /track/v2/projects/<projectToken>/customers/events` для отслеживания данных событий
* `POST /track/v2/projects/<projectToken>/campaigns/clicks` для отслеживания событий кампаний
* `POST /data/v2/projects/<projectToken>/consent/categories` для получения согласий
* `POST /webxp/s/<projectToken>/inappmessages?v=1` для получения InApp сообщений
* `POST /webxp/projects/<projectToken>/appinbox/fetch` для получения данных AppInbox
* `POST /webxp/projects/<projectToken>/appinbox/markasread` для отметки сообщения AppInbox как прочитанного
* `POST /campaigns/send-self-check-notification?project_id=<projectToken>` для части потока самопроверки push уведомлений

Разработчики должны установить токен, используя параметр конфигурации `authorization` при [инициализации SDK](https://documentation.bloomreach.com/engagement/docs/ios-sdk-setup#initialize-the-sdk):

```swift
Sendsay.shared.configure(
    projectToken: "YOUR PROJECT TOKEN",
    authorization: .token("YOUR API KEY")
)
```

## Авторизация по токену клиента

Авторизация по токену клиента является опциональной и обеспечивает [доступ к приватному API](https://documentation.bloomreach.com/engagement/reference/authentication#private-api-access) для выбранных endpoints Engagement API. [Токен клиента](https://documentation.bloomreach.com/engagement/docs/customer-token) содержит закодированные ID клиентов и подпись. Когда Bloomreach Engagement API получает токен клиента, он сначала проверяет подпись и обрабатывает запрос только в случае, если подпись действительна.

Токен клиента кодируется с использованием **JSON Web Token (JWT)**, открытого промышленного стандарта [RFC 7519](https://tools.ietf.org/html/rfc7519), который определяет компактный и самодостаточный способ безопасной передачи информации между сторонами.

SDK отправляет токен клиента в формате `Bearer <value>`. В настоящее время SDK поддерживает авторизацию по токену клиента для следующих endpoints Engagement API:

* `POST /webxp/projects/<projectToken>/appinbox/fetch` для получения данных AppInbox
* `POST /webxp/projects/<projectToken>/appinbox/markasread` для отметки сообщения AppInbox как прочитанного

Разработчики могут включить авторизацию по токену клиента, установив параметр [конфигурации](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configuration) `advancedAuthEnabled` в `true` при [инициализации SDK](https://documentation.bloomreach.com/engagement/docs/ios-sdk-setup#initialize-the-sdk):

```swift
Sendsay.shared.configure(
    projectToken: "YOUR PROJECT TOKEN",
    authorization: .token("YOUR API KEY"),
    advancedAuthEnabled: true
)
```

Дополнительно разработчики должны реализовать протокол `AuthorizationProviderType` (с атрибутом `@objc`), убедившись, что метод `getAuthorizationToken` возвращает действительный JWT токен, который кодирует соответствующие ID клиента(ов) и ID приватного API ключа:

```swift
@objc(SendsayAuthProvider)
public class ExampleAuthProvider: NSObject, AuthorizationProviderType {
    required public override init() { }
    public func getAuthorizationToken() -> String? {
        "YOUR JWT TOKEN"
    }
}
```

> ❗️
>
> Токены клиентов должны генерироваться стороной, которая может безопасно верифицировать личность клиента. Обычно это означает, что токены клиентов должны генерироваться во время процедуры входа в бэкенд приложения. Когда личность клиента верифицирована (с использованием пароля, аутентификации третьей стороны, единого входа и т.д.), бэкенд приложения должен сгенерировать токен клиента и отправить его на устройство, на котором работает SDK.

> 📘
>
> Обратитесь к [Генерация токена клиента](https://documentation.bloomreach.com/engagement/docs/customer-token#generating-customer-token) в документации по токенам клиентов для пошаговых инструкций по генерации JWT токена клиента.

### Устранение неполадок

Если вы определили `SendsayAuthProvider`, но он не работает как ожидается, проверьте логи на следующее:
1. Если вы включили авторизацию по токену клиента, установив флаг конфигурации `advancedAuthEnabled` в `true`, но SDK не может найти реализацию провайдера, он запишет следующее сообщение:
`Advanced authorization flag has been enabled without provider`
2. Зарегистрированный класс должен расширять `NSObject`. Если этого нет, вы увидите следующее сообщение в логе:
`Class SendsayAuthProvider does not conform to NSObject`
3. Зарегистрированный класс должен соответствовать `AuthorizationProviderType`. Если этого нет, вы увидите следующее сообщение в логе:
`Class SendsayAuthProvider does not conform to AuthorizationProviderType`

### Асинхронная реализация AuthorizationProvider

Значение токена клиента запрашивается для каждого HTTP вызова во время выполнения. Метод `getAuthorizationToken()` написан для синхронного использования, но вызывается в фоновом потоке. Поэтому вы можете заблокировать любое асинхронное получение токена (т.е. другой HTTP вызов) и ждать результата, блокируя этот поток. Если получение токена не удается, вы можете вернуть значение NULL, но запрос автоматически завершится неудачей.

```swift
@objc(SendsayAuthProvider)
public class ExampleAuthProvider: NSObject, AuthorizationProviderType {
    required public override init() { }
    public func getAuthorizationToken() -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var token: String?
        let task = yourAuthTokenReqUrl.dataTask(with: request) {
            token = $0
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return token
    }
}
```

> 👍
>
> Различные сетевые библиотеки поддерживают разные подходы, но принцип остается тем же - не стесняйтесь блокировать вызов метода `getAuthorizationToken`.

### Политика получения токена клиента

Значение токена клиента запрашивается для каждого HTTP вызова, который его требует.

Обычно JWT токены имеют свой собственный срок действия и могут использоваться несколько раз. SDK не хранит токен в каком-либо кэше. Разработчики могут реализовать свой собственный кэш токенов по своему усмотрению. Например:

```swift
@objc(SendsayAuthProvider)
public class ExampleAuthProvider: NSObject, AuthorizationProviderType {
    required public override init() { }

    private var tokenCache: String?
    private var lifetime: Double?

    public func getAuthorizationToken() -> String? {
        if tokenCache == nil || hasExpired(lifetime) {
            (tokenCache, lifetime) = loadJwtToken()
        }
        return tokenCache
    }

    private func loadJwtToken() -> String? {
        ...
    }
}
```

> ❗️
>
> Пожалуйста, рассмотрите возможность более безопасного хранения вашего кэшированного токена. iOS предлагает несколько вариантов, таких как [Keychain](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_keychain) или [CryptoKit](https://developer.apple.com/documentation/cryptokit/).

> ❗️
>
> Токен клиента действителен до истечения срока действия и назначается текущим ID клиентов. Имейте в виду, что если ID клиентов изменяются (из-за вызова методов `identifyCustomer` или `anonymize`), токен клиента может стать недействительным для будущих HTTP запросов, вызванных для новых ID клиентов.