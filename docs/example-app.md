---
title: Пример приложения
excerpt: Сборка, запуск и навигация по примеру приложения, включенному в iOS SDK
slug: ios-sdk-example-app
categorySlug: integrations
parentDocSlug: ios-sdk
---

iOS SDK Sendsay включает пример приложения, который можно использовать в качестве эталонной реализации. Вы можете собрать и запустить приложение, протестировать функции Engagement и сравнить код и поведение вашей реализации с ожидаемым поведением и кодом в примере приложения.

## Требования

Для сборки и запуска примера приложения у вас должно быть установлено следующее программное обеспечение:

- Xcode
- [CocoaPods](https://cocoapods.org/)

В Xcode перейдите в `Xcode` > `Preferences` > `Locations` и убедитесь, что `Command Line Tools` установлен на вашу версию Xcode.

## Сборка и запуск примера приложения

1. Клонируйте репозиторий [sendsay-ios-sdk](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios) на GitHub:
   ```shell
   git clone https://github.com/sendsay-ru/sendsay-mobile-sdk-ios.git
   ```
2. Выполните следующую команду CocoaPods:
   ```shell
   pod install
   ```
3. Откройте файл `SendsaySDK.xcworkspace`, чтобы открыть проект в Xcode.
4. В навигаторе проекта в Xcode выберите проект `SendsaySDK`.
5. Перейдите к настройкам целевого приложения `Example`. На вкладке `General` найдите раздел `Frameworks, Libraries, and Embedded Content`.
6. Перейдите в `Product` > `Scheme` и выберите `Example`.
7. Выберите `Product` > `Build` (Cmd + B).
8. Выберите `Product` > `Run` (Cmd + R), чтобы запустить пример приложения в симуляторе.

> 📘
>
> Чтобы включить push-уведомления в примере приложения, вы также должны [настроить интеграцию Apple Push Notification Service](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configure-apns) в веб-приложении Sendsay.

## Навигация по примеру приложения

![Экраны примера приложения: конфигурация, получение данных, отслеживание, отслеживание событий](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/sample-app-1.png)

Когда вы запускаете приложение в симуляторе, вы увидите представление **Authentication**. Введите ваш [токен проекта, API токен и базовый URL API](https://documentation.bloomreach.com/engagement/docs/mobile-sdks-api-access-management), затем нажмите `Start`, чтобы [инициализировать SDK](https://documentation.bloomreach.com/engagement/docs/ios-sdk-setup#initialize-the-sdk).
> [`AuthenticationViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/AuthenticationViewController.swift)

Приложение предоставляет несколько представлений, доступных через нижнюю навигацию, для тестирования различных функций SDK:

- Представление **Fetch Data** позволяет получать рекомендации и согласия, а также открывать почтовый ящик приложения.
  > [`FetchViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Fetching/FetchViewController.swift)

- Представление **Tracking** позволяет тестировать отслеживание различных событий и свойств. Кнопки `Custom Event` и `Identify Customer` ведут к отдельным представлениям для ввода тестовых данных.
  > [`TrackingViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Tracking/TrackingViewController.swift)
  > [`TrackEventViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Tracking/TrackEventViewController.swift)
  > [`IdentifyCustomerViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Tracking/IdentifyCustomerViewController.swift)

- Представление **Flushing** позволяет запустить ручную отправку данных, анонимизировать данные клиента и выйти из системы.
  > [`FlushingViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Flushing/FlushingViewController.swift)

- Представление **Logging** отображает сообщения журнала от SDK.
  > [`LogViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Logging/LogViewController.swift)

- Представление **In-app Content Blocks** отображает блоки контента в приложении. Используйте ID плейсхолдеров `example_top`, `ph_x_example_iOS`, `example_list`, `example_carousel` и `example_carousel_ios` в настройках ваших блоков контента в приложении.
  > [`InAppContentBlocksViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/InAppContentBlocks/InAppContentBlocksViewController.swift)
  > [`InAppContentBlockCarouselViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/InAppContentBlocks/InAppContentBlockCarouselViewController.swift)

Попробуйте различные функции в приложении, затем найдите профиль клиента в веб-приложении Engagement (в разделе `Data & Assets` > `Customers`), чтобы увидеть свойства и события, отслеживаемые SDK.

До тех пор, пока вы не используете `Identify Customer` в приложении, клиент отслеживается анонимно, используя cookie soft ID. Вы можете найти значение cookie в логах и найти соответствующий профиль в веб-приложении Engagement.

После того, как вы используете `Identify Customer` в приложении для установки hard ID `registered` (используйте адрес электронной почты в качестве значения), клиент идентифицируется и может быть найден в веб-приложении Engagement по его адресу электронной почты.

> 📘
>
> Обратитесь к [Идентификация клиента](https://documentation.bloomreach.com/engagement/docs/customer-identification) для получения дополнительной информации о soft ID и hard ID.

![Экраны примера приложения: идентификация, отправка данных, логирование, блоки контента](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/sample-app-2.png)

## Устранение неполадок

Если у вас возникли проблемы при сборке примера приложения, следующее может помочь:

- Удалите папку `Pods` и файл `Podfile.lock` из папки проекта и повторно выполните команду `pod install`.
- В Xcode выберите `Product` > `Clean Build Folder` (Cmd + Shift + K), затем `Product` > `Build` (Cmd + B).