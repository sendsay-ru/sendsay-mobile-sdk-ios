---
title: Конфигурация
excerpt: Полная справочная информация по конфигурации iOS SDK
slug: ios-sdk-configuration
categorySlug: integrations
parentDocSlug: ios-sdk-setup
---

Эта страница предоставляет обзор всех параметров конфигурации для SDK и несколько примеров того, как инициализировать SDK с различными конфигурациями.

## Параметры конфигурации

* `projectToken` **(обязательный)**
   * Ваш токен проекта. Вы можете найти его в веб-приложении Engagement в разделе `Project settings` > `Access management` > `API`.

* `authorization` **(обязательный)**
   * Варианты: `.none` или `.token(token)`.
   * Токен должен быть **публичным** ключом Engagement. См. [Управление доступом к API мобильных SDK](https://documentation.bloomreach.com/engagement/docs/mobile-sdks-api-access-management) для получения подробностей.
   * Для получения дополнительной информации обратитесь к [документации Bloomreach Engagement API](https://documentation.bloomreach.com/engagement/reference/authentication).

* `baseUrl`
  * Ваш базовый URL API, который можно найти в веб-приложении Engagement в разделе `Project settings` > `Access management` > `API`.
  * Значение по умолчанию: `https://api.sendsay.com`.
  * Если у вас есть пользовательский базовый URL, вы должны установить это свойство.

* `projectMapping`
  * Если вам нужно отслеживать события в более чем одном проекте, вы можете определить информацию о проекте для "типов событий", которые должны отслеживаться несколько раз.

* `defaultProperties`
  * Список свойств, которые будут добавлены ко всем событиям отслеживания.
  * Значение по умолчанию: `nil`

* `allowDefaultCustomerProperties`
  * Флаг для применения списка `defaultProperties` к событию отслеживания `identifyCustomer`
  * Значение по умолчанию: `true`

* `automaticSessionTracking`
  * Флаг для управления автоматическим отслеживанием событий `session_start` и `session_end`.
  * Значение по умолчанию: `true`

* `sessionTimeout`
  * Сессия - это фактическое время, проведенное в приложении. Она начинается при запуске приложения и заканчивается, когда приложение переходит в фон.
  * Это значение используется для расчета времени сессии.
  * Значение по умолчанию: `60.0` секунд.
  * Минимальное значение: `5.0` секунд.
  * **Рекомендуемое** максимальное значение: `120.0` секунд, но **абсолютный** максимум составляет `180.0` секунд. Большее значение приведет к тому, что iOS завершит сессию.
  * Подробнее читайте в разделе [Отслеживание сессий](tracking#session)

* `automaticPushNotificationTracking` - УСТАРЕЛ
  * Управляет тем, будет ли SDK автоматически обрабатывать push-уведомления с использованием method swizzling. Эта функция устарела, поскольку ее использование method swizzling может вызвать проблемы в случае, если хост-приложение использует несколько SDK, которые делают то же самое.
  * Заменено на `pushNotificationTracking`. С `pushNotificationTracking` у вас больше контроля над тем, что происходит внутри вашего приложения, в дополнение к упрощению отладки. При миграции с `automaticPushNotificationTracking` требуется дополнительная работа. Обратитесь к документации [Push-уведомления](https://documentation.bloomreach.com/engagement/docs/ios-sdk-push-notifications) для получения подробностей.
  * Значение по умолчанию: `true`

* `pushNotificationTracking`
  * Управляет тем, будет ли SDK обрабатывать push-уведомления. Регистрирует приложение для получения push-уведомлений на основе настройки `requirePushAuthorization`.
  * Значение по умолчанию: `true`

* `appGroup`
  * **Обязательно** для того, чтобы SDK автоматически отслеживал доставленные push-уведомления. Обратитесь к документации [Push-уведомления](https://documentation.bloomreach.com/engagement/docs/ios-sdk-push-notifications) для получения подробностей.

* `requirePushAuthorization`
  * SDK может проверить статус авторизации push-уведомлений ([документация Apple](https://developer.apple.com/documentation/usernotifications/unnotificationsettings/1648391-authorizationstatus)) и отслеживать push-токен только в том случае, если пользователь авторизован для получения push-уведомлений.
  * При отключении SDK автоматически зарегистрируется для push-уведомлений при запуске приложения и отследит токен в Engagement, чтобы ваше приложение могло получать тихие push-уведомления.
  * При включении SDK автоматически зарегистрируется для push-уведомлений, если приложение авторизовано показывать push-уведомления пользователю.
  * Значение по умолчанию: `true`

* `tokenTrackFrequency`
  * Указывает частоту, с которой токен APNs должен отслеживаться в Engagement.
  * Значение по умолчанию: `onTokenChange`
  * Возможные значения:
    * `onTokenChange` - отслеживает push-токен, если он отличается от ранее отслеженного
    * `everyLaunch` - всегда отслеживает push-токен
    * `daily` - отслеживает push-токен раз в день

* `flushEventMaxRetries`
  * Управляет тем, сколько раз событие должно быть отправлено перед прерыванием. Полезно, например, в случае недоступности API или других временных ошибок.
  * Значение по умолчанию: `5`

* `advancedAuthEnabled`
  * Если установлено в `true`, SDK использует авторизацию по [токену клиента](https://documentation.bloomreach.com/engagement/docs/customer-token) для связи с API Engagement, перечисленными в [Авторизация по токену клиента](https://documentation.bloomreach.com/engagement/docs/ios-sdk-authorization#customer-token-authorization).
  * Обратитесь к [документации по авторизации](https://documentation.bloomreach.com/engagement/docs/ios-sdk-authorization) для получения подробностей.
  * Значение по умолчанию: `false`

* `inAppContentBlocksPlaceholders`
  * Если установлено, все [блоки контента в приложении](https://documentation.bloomreach.com/engagement/docs/ios-sdk-in-app-content-blocks) будут предварительно загружены сразу после инициализации SDK.

* `manualSessionAutoClose`
  * Определяет, должен ли SDK автоматически отслеживать `session_end` для сессий, которые остаются открытыми, когда `Sendsay.shared.trackSessionStart()` вызывается несколько раз в режиме ручного отслеживания сессий.
  * Значение по умолчанию: `true`

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
  * В большинстве случаев использования требуются только `projectToken` и `authorization`.

* `pushNotificationTracking` **(обязательный)**
  * Либо `.disabled`, либо `.enabled(appGroup, delegate, requirePushAuthorization, tokenTrackFrequency)`. Только `appGroup` требуется для корректной работы SDK.
  * Установка `delegate` имеет тот же эффект, что и установка `Sendsay.shared.pushNotificationsDelegate`.

* `automaticSessionTracking`
  * Либо `.disabled`, либо `.enabled(timeout)`.
  * Значение по умолчанию: `enabled()` (рекомендуется, использует таймаут сессии по умолчанию)

* `defaultProperties`
  * Как описано выше в [Параметры конфигурации](#параметры-конфигурации).

* `flushingSetup`
  * Позволяет настроить `flushingMode` и `maxRetries`. По умолчанию отправка событий происходит как только вы отслеживаете событие (`.immediate`). Вы можете изменить это поведение на одно из `.manual`, `.automatic`, `periodic(period)`.
  * См. [Отправка данных](https://documentation.bloomreach.com/engagement/docs/ios-sdk-data-flushing) для получения подробностей.

#### Примеры
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


### Использование файла конфигурации - УСТАРЕЛО
> ❗️ 
> 
> Настройка SDK с использованием файла `plist` устарела, но все еще поддерживается для обратной совместимости.

Создайте файл конфигурации `.plist`, содержащий как минимум обязательные переменные конфигурации.
``` swift
public func configure(plistName: String)
```

#### Пример

```
Sendsay.shared.configure(plistName: "ExampleConfig.plist")
```


*ExampleConfig.plist*

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