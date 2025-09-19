---
title: Первоначальная настройка SDK
excerpt: Установка и настройка iOS SDK
slug: ios-sdk-setup
categorySlug: integrations
parentDocSlug: ios-sdk
---

## Установка SDK

iOS SDK Sendsay можно установить или обновить с помощью [CocoaPods](https://cocoapods.org/) или [Swift Package Manager](https://www.swift.org/package-manager/).

Приведенные ниже инструкции предназначены для Xcode 15.1 и могут отличаться при использовании другой версии Xcode.

### CocoaPods

1. Установите [CocoaPods](https://cocoapods.org/), если вы еще этого не сделали.
2. Создайте файл с именем `Podfile` в папке вашего проекта Xcode.
3. Добавьте следующее в ваш `Podfile`
   ```
   platform :ios, '13.0'
   use_frameworks!

   target 'YourAppTarget' do
     pod "SendsaySDK"
   end
   ```
   (Замените `13.0` на желаемую версию iOS для развертывания и `YourAppTarget` на имя цели вашего приложения)
4. В окне терминала перейдите в папку проекта Xcode и выполните следующую команду:
    ```
    pod install
    ```
5. Откройте файл `HelloWorld.xcworkspace`, расположенный в папке вашего проекта, в XCode.
6. В Xcode выберите ваш проект, затем перейдите на вкладку `Build Settings`. В разделе `Build Options` измените `User Script Sandboxing` с `Yes` на `No`.

При желании вы можете указать версию `SendsaySDK` следующим образом, чтобы `pod` автоматически получал любые обновления меньше минорной версии:
```
pod "SendsaySDK", "~> 3.6.0"
```
Для получения дополнительной информации обратитесь к [Указанию версий pod](https://guides.cocoapods.org/using/the-podfile.html#specifying-pod-versions) в документации Cocoapods.

### Swift Package Manager

1. В Xcode перейдите в `Xcode -> Settings -> Accounts` и добавьте свою учетную запись GitHub, если вы еще этого не сделали.
2. Откройте `File -> Add Package Dependencies...`
3. В появившемся диалоговом окне введите URL репозитория Sendsay iOS SDK `https://github.com/sendsay/sendsay-ios-sdk` в поле поиска.
4. В разделе `Dependency Rule` выберите версию SDK.
   ![Диалог Add Package Dependencies](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/swift-pm-1.png)
5. Нажмите на `Add Package`.
6. В следующем диалоговом окне убедитесь, что выбраны и `SendsaySDK`, и `SendsaySDK-Notifications`.
   ![Диалог Choose Packages](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/swift-pm-2.png)
7. Нажмите на `Add Package`.

## Инициализация SDK

Теперь, когда вы установили SDK в свой проект, вы должны импортировать, настроить и инициализировать SDK в коде вашего приложения.

> ❗️ Защитите конфиденциальность ваших клиентов
 >
 > Убедитесь, что вы получили и сохранили согласие на отслеживание от вашего клиента перед инициализацией Sendsay iOS SDK.
 >
 > Чтобы убедиться, что вы не отслеживаете события без согласия клиента, вы можете использовать `Sendsay.shared.clearLocalCustomerData(appGroup: String)`, когда клиент отказывается от отслеживания (это применимо к новым пользователям или возвращающимся клиентам, которые ранее отказались). Это приведет SDK в состояние, как если бы он никогда не был инициализирован. Эта опция также предотвращает повторное использование существующих cookies для возвращающихся клиентов.
 >
 > Обратитесь к [Очистка локальных данных клиента](https://documentation.bloomreach.com/engagement/docs/ios-sdk-tracking#clear-local-customer-data) для получения подробностей.
 >
 > Если клиент отказывается от согласия на отслеживание после инициализации Sendsay iOS SDK, вы можете использовать `Sendsay.shared.stopIntegration()` для остановки интеграции SDK и удаления всех локально сохраненных данных.
 >
 > Обратитесь к [Остановка интеграции SDK](https://documentation.bloomreach.com/engagement/docs/ios-sdk-tracking#stop-sdk-integration) для получения подробностей.

Обязательными параметрами конфигурации являются `projectToken`, `authorization.token` и `baseUrl`. Вы можете найти их как `Project token`, `API Token` и `API Base URL` в веб-приложении Bloomreach Engagement в разделе `Project settings` > `Access management` > `API`:

![Project token, API Base URL и API key](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/api-access-management.png)

> 📘
>
> Обратитесь к [Управление доступом к API мобильных SDK](https://documentation.bloomreach.com/engagement/docs/mobile-sdks-api-access-management) для получения подробностей.

Импортируйте SDK:

```swift
import SendsaySDK
```

Инициализируйте SDK:

```swift
Sendsay.shared.configure(
  Sendsay.ProjectSettings(
    projectToken: "YOUR PROJECT TOKEN",
    authorization: .token("YOUR API KEY"),
    baseUrl: "https://api.sendsay.com"
  ),
  pushNotificationTracking: .disabled
)
```

Метод `application:didFinishLaunchingWithOptions` вашего `AppDelegate` обычно является хорошим местом для инициализации, но в зависимости от дизайна вашего приложения это может быть где угодно в вашем коде.

На этом этапе SDK активен и теперь должен отслеживать клиентов и события в вашем приложении.

Инициализация SDK немедленно создает новый профиль клиента с новым cookie [soft ID](https://documentation.bloomreach.com/engagement/docs/customer-identification#soft-id), если клиент не был [идентифицирован](https://documentation.bloomreach.com/engagement/docs/ios-sdk-tracking#identify) ранее.

> 📘
>
> Обратитесь к [Отслеживание](https://documentation.bloomreach.com/engagement/docs/ios-sdk-tracking) для получения подробностей о том, какие события автоматически отслеживаются SDK.

> ❗️ 
> 
> [Настройка SDK с помощью файла `plist`](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configuration#using-a-configuration-file---legacy) устарела, но все еще поддерживается для обратной совместимости.

## Другие настройки SDK

### Расширенная конфигурация

SDK можно дополнительно настроить, предоставив дополнительные параметры методу `configure`. Для полного списка доступных параметров конфигурации обратитесь к документации [Конфигурация](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configuration).

### Уровень логирования

SDK поддерживает следующие уровни логирования:

| Уровень логирования  | Описание |
| -----------| ----------- |
| `.none`    | Отключает все логирование |
| `.error`   | Серьезные ошибки или критические проблемы |
| `.warning` | Предупреждения и рекомендации + `.error` |
| `.verbose` | Информация обо всех действиях SDK + `.warning` + `.error`. |

Уровень логирования по умолчанию — `.warn`. При разработке или отладке установка уровня логирования на `.verbose` может быть полезной.

Вы можете установить уровень логирования во время выполнения следующим образом:

```swift
Sendsay.logger.logLevel = .verbose
```
  
> 👍 
> 
> Для лучшей видимости сообщения журнала от SDK имеют префикс `[SEND-iOS]`.

### Авторизация

Прочитайте [Авторизация](https://documentation.bloomreach.com/engagement/docs/ios-sdk-authorization), чтобы узнать больше о различных режимах авторизации, поддерживаемых SDK, и о том, как использовать авторизацию [токена клиента](https://documentation.bloomreach.com/engagement/docs/customer-token).

### Отправка данных

Прочитайте [Отправка данных](https://documentation.bloomreach.com/engagement/docs/ios-sdk-data-flushing), чтобы узнать больше о том, как SDK загружает данные в Engagement API и как настроить это поведение.
