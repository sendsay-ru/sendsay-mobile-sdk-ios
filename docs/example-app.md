---
title: Пример приложения
excerpt: Сборка, запуск и навигация по примеру приложения, включённому в iOS SDK
slug: ios-sdk-example-app
categorySlug: integrations
parentDocSlug: ios-sdk
---

iOS SDK Sendsay включает пример приложения, который можно использовать как эталонную реализацию. Вы можете собрать и запустить его, протестировать функции CDP Sendsay и сравнить свой код с ожидаемым поведением и кодом в примере.

## Требования

Для сборки и запуска примера приложения установите:

- Xcode
- [CocoaPods](https://cocoapods.org/)

В Xcode перейдите в **Xcode** > **Preferences** > **Locations** и убедитесь, что в поле **Command Line Tools** выбрана ваша версия Xcode.

## Сборка и запуск примера приложения

1. Клонируйте репозиторий [sendsay-ios-sdk](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios) на GitHub:
   ```shell
   git clone https://github.com/sendsay-ru/sendsay-mobile-sdk-ios.git
   ```
2. Выполните команду CocoaPods:
   ```shell
   pod install
   ```
3. Откройте проект в Xcode через файл **SendsaySDK.xcworkspace**.
4. В навигаторе проекта выберите проект **SendsaySDK**.
5. Перейдите в настройки целевого приложения `Example` и откройте вкладку **General** > **Frameworks, Libraries, and Embedded Content**.
6. В меню **Product** > **Scheme** выберите схему `Example`.
7. Выполните сборку: **Product** > **Build** (Cmd + B).
8. Запустите приложение в симуляторе: **Product** > **Run** (Cmd + R).

> 📘
>
> Чтобы протестировать push-уведомления настройте [интеграцию Apple Push Notification Service](https://docs.sendsay.ru/other-channels/mobile-push/how-to-connect-mobile-push/#%D0%BA%D0%B0%D0%BA-%D0%BF%D0%BE%D0%B4%D0%BA%D0%BB%D1%8E%D1%87%D0%B8%D1%82%D1%8C-%D0%BF%D1%80%D0%B8%D0%BB%D0%BE%D0%B6%D0%B5%D0%BD%D0%B8%D0%B5-%D0%B2-%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D1%84%D0%B5%D0%B9%D1%81%D0%B5-sendsay) в веб-приложении Sendsay.

## Навигация по примеру приложения

![Экраны примера приложения: авторизация](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-ios/main/docs/img/sample-app-1.png)
![Экраны примера приложения: отслеживание, логирование, отслеживание событий, индентификация пользователя](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-ios/main/docs/img/sample-app-2.png)

После запуска приложения откроется экран **Authentication**. Введите [ID проекта, токен авторизации и базовый URL API](configuration#параметры-конфигурации), затем нажмите «Start», чтобы [инициализировать SDK](setup.md#инициализация-sdk).
> [`AuthenticationViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/AuthenticationViewController.swift)

Приложение содержит несколько экранов, доступных через нижнюю навигацию:

- **Fetch Data** — получение рекомендаций, согласий и открытие почтового ящика.
  > [`FetchViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Fetching/FetchViewController.swift)

- **Tracking** — тестирование отслеживания событий и свойств. Кнопки «Custom Event» и «Identify Customer» открывают отдельные формы для ввода данных.
  > [`TrackingViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Tracking/TrackingViewController.swift)
  > [`TrackEventViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Tracking/TrackEventViewController.swift)
  > [`IdentifyCustomerViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Tracking/IdentifyCustomerViewController.swift)

- **Flushing** — ручная отправка данных, анонимизация профиля и выход из системы.
  > [`FlushingViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Flushing/FlushingViewController.swift)

- **Logging** — просмотр логов SDK.
  > [`LogViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/Logging/LogViewController.swift)

- **In-app Content Blocks** — просмотр блоков контента в приложении. Используйте ID плейсхолдеров: `example_top`, `ph_x_example_iOS`, `example_list`, `example_carousel` и `example_carousel_ios`.
  > [`InAppContentBlocksViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/InAppContentBlocks/InAppContentBlocksViewController.swift)
  > [`InAppContentBlockCarouselViewController.swift`](https://github.com/sendsay-ru/sendsay-mobile-sdk-ios/blob/main/SendsaySDK/Example/Views/InAppContentBlocks/InAppContentBlockCarouselViewController.swift)

Попробуйте разные функции, а затем найдите профиль клиента в веб-приложении CDP Sendsay (в разделе **Data & Assets** > **Customers**), чтобы увидеть свойства и события, отслеживаемые SDK.

До тех пор, пока вы не используете `Identify Customer` в приложении, клиент остаётся анонимным, используя **soft ID** (*cookie*). Значение cookie отображается в логах и позволяет найти соответствующий профиль в веб-приложении CDP Sendsay.

После использования `Identify Customer` профиль получает **hard ID** (*registered*). Обычно в качестве значения используют email — по нему профиль можно найти в веб-приложении CDP Sendsay.

> 📘
>
> Подробнее о soft ID и hard ID — в разделе [Идентификация клиента](tracking.md#Идентификация) документации CDP Sendsay.

![Экраны примера приложения: идентификация, отправка данных, логирование, блоки контента](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-ios/main/Documentation/images/sample-app-2.png)

## Устранение неполадок

Если возникают проблемы со сборкой или запуском:

- Удалите папку **Pods** и файл **Podfile.lock** из папки проекта, затем выполните команду `pod install` повторно.
- В Xcode выберите **Product** > **Clean Build Folder** (Cmd + Shift + K), затем **Product** > **Build** (Cmd + B).