## Установка SDK

iOS SDK Sendsay можно установить или обновить через [CocoaPods](https://cocoapods.org/) или [Swift Package Manager](https://www.swift.org/package-manager/).

Инструкции ниже подготовлены для Xcode 15.1 — в других версиях интерфейс может отличаться.

### CocoaPods

1. Установите [CocoaPods](https://cocoapods.org/), если он ещё не установлен.
2. Создайте файл **Podfile** в корне проекта Xcode.
3. Добавьте в него
   ```
   platform :ios, '13.0'
   use_frameworks!

   target 'YourAppTarget' do
     pod "SendsaySDK"
   end
   ```
   Замените:
   * `13.0` — на желаемую версию iOS для развёртывания.
   * `YourAppTarget` — на имя цели (таргет) вашего приложения.
4. В терминале перейдите в папку проекта и выполните:
    ```
    pod install
    ```
5. Откройте файл **HelloWorld.xcworkspace**, расположенный в папке вашего проекта, в XCode.
6. В Xcode перейдите в **Build Settings**. раздел **Build Options**, и установите `User Script Sandboxing` > `No`.

Чтобы фиксировать только мажорную версию SDK и разрешить обновления внутри минорных:
```
pod "SendsaySDK", "~> 0.2.0"
```
Подробнее — в разделе [Указанию версий pod](https://guides.cocoapods.org/using/the-podfile.html#specifying-pod-versions) документации Cocoapods.

### Swift Package Manager

1. В Xcode откройте **Xcode** > **Settings** > **Accounts** и при необходимости добавьте свою учётную запись GitHub.
2. Выберите **File** > **Add Package Dependencies...**
3. Введите URL SDK:
    ```
    https://github.com/sendsay-ru/sendsay-mobile-sdk-ios
    ``` 
4. В диалоговом окне **Dependency Rule** выберите нужную версию SDK.

    ![Диалог Add Package Dependencies](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-ios/main/docs/img/xcode-pm-1.png)

5. Нажмите «Add Package».
6. В следующем окне выберите оба пакета: `SendsaySDK`, и `SendsaySDK-Notifications`.

    ![Диалог Choose Packages](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-ios/main/docs/img/xcode-pm-2.png)

7. Нажмите «Add Package».

## Инициализация SDK

После установки SDK вам нужно импортировать его в проект, указать параметры конфигурации и выполнить инициализацию.

Обязательные параметры конфигурации:
* `projectToken`,
* `authorization`,
* `baseUrl`.

Эти значения можно найти в [личном кабинете](https://app.sendsay.ru/dashboard) CDP Sendsay в разделе
**Подписчики** > **Мобильное приложение** > **Настройки приложения**.

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
    baseUrl: "https://mobi.sendsay.ru/xnpe/v100/json"
  ),
  pushNotificationTracking: .disabled
)
```

Обычно инициализацию выполняют в методе `application:didFinishLaunchingWithOptions` вашего `AppDelegate`, но при необходимости её можно разместить в другом месте приложения.

После инициализации SDK:
* начинает отслеживать клиентов и события,
* создаёт новый профиль клиента с новым cookie, если пользователь ещё не был [идентифицирован](../docs/tracking.md#идентификация).

> 📘
>
> Подробности об автоматически отслеживаемых событиях смотрите в разделе [Отслеживание](../docs/tracking.md).

## Другие настройки SDK

### Расширенная конфигурация

Полный список настроек, которые можно передать в `configure`, приведён в разделе [Конфигурация](../docs/configuration.md).

### Уровень логирования

SDK поддерживает несколько уровней логирования:

| Уровень логирования  | Описание |
| -----------| ----------- |
| `.none`    | Отключает всё логирование |
| `.error`   | Серьёзные ошибки или критические проблемы |
| `.warning` | Предупреждения и рекомендации + `.error` |
| `.verbose` | Информация обо всех действиях SDK + `.warning` + `.error`. |

По умолчанию используется уровень `.warning`. При разработке или отладке может быть полезно установить уровень логирования `.verbose`.

Чтобы изменить уровень:

```swift
Sendsay.logger.logLevel = .verbose
```
  
> 👍 
> 
> Логи SDK имеют префикс `[SEND-iOS]`.

### Авторизация

Подробнее о режимах авторизации — в разделе [Авторизация](../docs/authorization.md).

### Отправка данных

Как SDK отправляет данные и как настроить это поведение — в разделе [Отправка данных](../docs/data-flushing.md).
