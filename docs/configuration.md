---
title: Конфигурация
excerpt: Полная справочная информация по конфигурации iOS SDK
slug: ios-sdk-configuration
categorySlug: integrations
parentDocSlug: ios-sdk-setup
---

На этой странице собраны все параметры конфигурации iOS SDK и примеры инициализации с разными настройками.

## Параметры конфигурации

* `projectToken` **(обязательный)**
   * Токен проекта. Его можно посмотреть в веб-приложении Engagement в разделе `Project settings` > `Access management` > `API`.

* `authorization` **(обязательный)**
   * Поддерживает варианты: `.none` или `.token(token)`.
   * Используйте **публичный** API-ключ Engagement. 
   * Подробнее — в разделах [Управление доступом к API мобильных SDK](https://documentation.bloomreach.com/engagement/docs/mobile-sdks-api-access-management) и [Authentication API](https://documentation.bloomreach.com/engagement/reference/authentication) в документации Engagement.

* `baseUrl`
  * Базовый URL API. По умолчанию: `https://api.sendsay.com`. 
  * Укажите своё значение, если используйте пользовательский базовый URL.

* `projectMapping`
  * Позволяет отслеживать события в нескольких проектах. Используйте, если отдельные «типы событий» должны отслеживать несколько раз и отправляться в разные проекты.

* `defaultProperties`
  * Свойства, которые SDK добавляет ко всем событиям отслеживания.
  * По умолчанию: `nil`.

* `allowDefaultCustomerProperties`
  * Применяет список `defaultProperties` к событию отслеживания `identifyCustomer`.
  * По умолчанию: `true`.

* `automaticSessionTracking`
  * Включает автоматическое отслеживание событий `session_start` и `session_end`.
  * По умолчанию: `true`.

* `sessionTimeout`
  * Время сессии в секундах.
  * По умолчанию — `60.0`, минимум — `5.0`, рекомендуемый максимум — `120.0`, абсолютный максимум — `180.0`.
  * Большее значение приведет к тому, что iOS завершит сессию. 
  * Подробнее — в разделе [Отслеживание сессий](tracking#session).
  
  > ❗️ 
  > 
  > Сессия — это фактическое время, проведенное в приложении. Она начинается при запуске приложения и заканчивается, когда приложение переходит в фон.

* `automaticPushNotificationTracking` (устарело)
  * Ранее управляло обработкой push-уведомлений через method swizzling.
  * Заменено на `pushNotificationTracking`.
  * По умолчанию: `true`.
  
  > ❗️ 
  > 
  > С функцией `pushNotificationTracking` у вас больше контроля над тем, что происходит внутри вашего приложения и упрощённая отладка. При миграции с `automaticPushNotificationTracking` потребуются допольнительные настройки, подробнее — в документации Engagement: [Push-уведомления](https://documentation.bloomreach.com/engagement/docs/ios-sdk-push-notifications).

* `pushNotificationTracking`
  * Управляет обработкой push-уведомлений и регистрацией приложения для получения push-уведомлений на основе настройки `requirePushAuthorization`.
  * По умолчанию: `true`.

* `appGroup`
  * **Обязательно** для автоматического отслеживания доставленных push-уведомлений. 
  * Подробнее — в документации Engagement: [Push-уведомления](https://documentation.bloomreach.com/engagement/docs/ios-sdk-push-notifications).

* `requirePushAuthorization`
  * Определяет, должен ли SDK проверять разрешение на push-уведомления перед отправкой push-токена.
  * По умолчанию: `true`.
  
  > ❗️ 
  > 
  > SDK может проверить, разрешены ли push-уведомления, и отправлять push-токен только при наличии разрешения. Если параметр отключён, SDK автоматически зарегистрируется для получения push-уведомлений при запуске приложения и отправит токен в Engagement — это позволит приложению получать тихие уведомления. Если параметр включён, SDK зарегистрируется для push-уведомлений только после того, как пользователь даст разрешение. Подробнее — в [документации Apple](https://developer.apple.com/documentation/usernotifications/unnotificationsettings/1648391-authorizationstatus).

* `tokenTrackFrequency`
  * Частота отслеживания push-токена в Engagement.
  * По умолчанию: `onTokenChange` — отслеживает push-токен, если он отличается от ранее отслеженного.
  * Другие возможные значения:
    * `everyLaunch` — всегда отслеживает push-токен.
    * `daily` — отслеживает push-токен раз в день.

* `flushEventMaxRetries`
  * Количество попыток отправки события перед остановкой. Полезно в случае недоступности API или других временных ошибок.
  * По умолчанию: `5`.

* `advancedAuthEnabled`
  * Включает авторизацию по [токену клиента](https://documentation.bloomreach.com/engagement/docs/customer-token), если установлено в `true`.
  * По умолчанию: `false`.
  * Подробнее — в [документации по авторизации](https://documentation.bloomreach.com/engagement/docs/ios-sdk-authorization) Engagement.

* `inAppContentBlocksPlaceholders`
  * При включении SDK заранее загрузит [блоки контента](https://documentation.bloomreach.com/engagement/docs/ios-sdk-in-app-content-blocks) в приложении.

* `manualSessionAutoClose`
  * Определяет, должен ли SDK автоматически отслеживать `session_end` для сессий, которые остаются открытыми, когда `Sendsay.shared.trackSessionStart()` вызывается несколько раз в режиме ручного отслеживания сессий.
  * По умолчанию: `true`.

## Настройка SDK

### Программная настройка SDK
Конфигурация разделена на несколько объектов, которые передаются в функцию `Sendsay.shared.configure()`.
``` swift
func configure(
        _ projectSettings: ProjectSettings,
        pushNotificationTracking: PushNotificationTracking,
        automaticSessionTracking: AutomaticSessionTracking = .enabled(),
        defaultProperties: [String: JSONConvertible]? = nil,
        flushingSetup: FlushingSetup = FlushingSetup.default
    )
```

* `ProjectSettings` **(обязательный)**
  * Содержит основные настройки проекта: `projectToken`, `authorization`, `baseUrl` и `projectMapping`.
  * В большинстве случаев достаточно указать `projectToken` и `authorization`.

* `pushNotificationTracking` **(обязательный)**
  * Варианты: 
    * `.disabled`,
	* `.enabled(appGroup, delegate, requirePushAuthorization, tokenTrackFrequency)`. Для корректной работы обязателен `appGroup`.
  * Установка `delegate` эквивалентна указанию `Sendsay.shared.pushNotificationsDelegate`.

* `automaticSessionTracking`
  * `.disabled` или `.enabled(timeout)`.
  * По умолчанию: `enabled()`.

* `defaultProperties`
  * Работает так же, как описано выше — [Параметры конфигурации](#параметры-конфигурации).

* `flushingSetup`
  * Определяет режим отправки событий:
	* По умолчанию: `.immediate` — отправка происходит как только вы отслеживаете событие.
	* `.manual`.
	* `.automatic`.
	* `periodic(period)`.
  * Подробнее — в документации Engagement: [Отправка данных](https://documentation.bloomreach.com/engagement/docs/ios-sdk-data-flushing)

#### Примеры конфигурации
Наиболее распространенный случай использования:
``` swift
Sendsay.shared.configure(
	Sendsay.ProjectSettings(
		projectToken: "YOUR PROJECT TOKEN",
		authorization: .token("YOUR ACCESS TOKEN")
	),
	pushNotificationTracking: .enabled(appGroup: "YOUR APP GROUP")
)
```
Отключение всех автоматических функций SDK:
``` swift
Sendsay.shared.configure(
	Sendsay.ProjectSettings(
		projectToken: "YOUR PROJECT TOKEN",
		authorization: .token("YOUR ACCESS TOKEN")
	),
	pushNotificationTracking: .disabled,
	automaticSessionTracking: .disabled,
	flushingSetup: Sendsay.FlushingSetup(mode: .manual)
)
```
Сложный случай использования:
``` swift
Sendsay.shared.configure(
	Sendsay.ProjectSettings(
		projectToken: "YOUR PROJECT TOKEN",
		authorization: .token("YOUR ACCESS TOKEN")
		baseUrl: "YOUR URL",
		projectMapping: [
			.payment: [
				SendsayProject(
					baseUrl: "YOUR URL",
					projectToken: "YOUR OTHER PROJECT TOKEN",
					authorization: .token("YOUR OTHER ACCESS TOKEN")
				)
			]
		]
	),
	pushNotificationTracking: .enabled(
		appGroup: "YOUR APP GROUP",
		delegate: self,
		requirePushAuthorization: false,
		tokenTrackFrequency: .onTokenChange
	),
	automaticSessionTracking: .enabled(timeout: 123),
	defaultProperties: ["prop-1": "value-1", "prop-2": 123],
	flushingSetup: Sendsay.FlushingSetup(mode: .periodic(100), maxRetries: 5),
	advancedAuthEnabled: true
)
```


### Настройка через файл конфигурации (устарело)
> ❗️ 
> 
> Настройка SDK через файл `.plist` устарела, но остаётся доступной для обратной совместимости.

Создайте файл `.plist` с обязательными настройками:
``` swift
public func configure(plistName: String)
```
и передайте его имя в метод:
```
Sendsay.shared.configure(plistName: "ExampleConfig.plist")
```
#### Пример файла ExampleConfig.plist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<plist version="1.0">
<dict>
	<key>projectToken</key>
	<string>testToken</string>
	<key>sessionTimeout</key>
	<integer>20</integer>
	<key>projectMapping</key>
	<dict>
		<key>INSTALL</key>
		<array>
			<dict>
				<key>projectToken</key>
				<string>testToken1</string>
				<key>authorization</key>
				<string>Token authToken1</string>
			</dict>
		</array>
		<key>TRACK_EVENT</key>
		<array>
			<dict>
				<key>projectToken</key>
				<string>testToken2</string>
				<key>authorization</key>
				<string>Token authToken2</string>
			</dict>
			<dict>
				<key>projectToken</key>
				<string>testToken3</string>
				<key>authorization</key>
				<string></string>
			</dict>
		</array>
		<key>PAYMENT</key>
		<array>
			<dict>
				<key>baseUrl</key>
				<string>https://mock-base-url.com</string>
				<key>projectToken</key>
				<string>testToken4</string>
				<key>authorization</key>
				<string>Token authToken4</string>
			</dict>
		</array>
	</dict>
	<key>autoSessionTracking</key>
	<false/>
</dict>
</plist>
```