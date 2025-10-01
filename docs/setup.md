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
3. В появившемся диалоговом окне введите URL репозитория Sendsay iOS SDK `https://github.com/sendsay-ru/sendsay-mobile-sdk-ios` в поле поиска.
4. В разделе `Dependency Rule` выберите версию SDK.
   ![Диалог Add Package Dependencies](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/swift-pm-1.png)
5. Нажмите на `Add Package`.
6. В следующем диалоговом окне убедитесь, что выбраны и `SendsaySDK`, и `SendsaySDK-Notifications`.
   ![Диалог Choose Packages](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/swift-pm-2.png)
7. Нажмите на `Add Package`.

## Инициализация SDK

Теперь, когда вы установили SDK в свой проект, вы должны импортировать, настроить и инициализировать SDK в коде вашего приложения.

Обязательными параметрами конфигурации являются `projectToken`, `authorization` и `baseURL`. Вы можете найти их в личном кабинете CDP Sendsay в разделе `Подписчики` > `Мобильное приложение` > `Настройки приложения`.

Импортируйте SDK:

```swift
import SendsaySDK
```

Инициализируйте SDK:

```swift
Sendsay.shared.configure(
  Sendsay.ProjectSettings(
    projectToken: "ID вашего аккаунта в Sendsay",
    authorization: .token("YOUR API KEY"),
    baseUrl: "https://mobi.sendsay.ru/mobi/api/v100/json"
  ),
  pushNotificationTracking: .disabled
)
```

Метод `application:didFinishLaunchingWithOptions` вашего `AppDelegate` обычно является хорошим местом для инициализации, но в зависимости от дизайна вашего приложения это может быть где угодно в вашем коде.

На этом этапе SDK активен и теперь должен отслеживать клиентов и события в вашем приложении.

Инициализация SDK немедленно создает новый профиль клиента с новым cookie, если клиент не был [идентифицирован](../docs/tracking.md#identify) ранее.

> 📘
>
> Обратитесь к [Отслеживание](../docs/tracking.md) для получения подробностей о том, какие события автоматически отслеживаются SDK.

## Другие настройки SDK

### Расширенная конфигурация

SDK можно дополнительно настроить, предоставив дополнительные параметры методу `configure`. Для полного списка доступных параметров конфигурации обратитесь к документации [Конфигурация](../docs/configuration.md).

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

Прочитайте [Авторизация](../docs/authorization.md), чтобы узнать больше о различных режимах авторизации, поддерживаемых SDK.

### Отправка данных

Прочитайте [Отправка данных](../docs/data-flushing.md), чтобы узнать больше о том, как SDK загружает данные в CDP Sendsay и как настроить это поведение.
