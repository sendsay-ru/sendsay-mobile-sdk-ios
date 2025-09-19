---
title: Настройка Apple Push Notification Service
excerpt: Настройка интеграции Apple Push Notification Service для Engagement
slug: ios-sdk-configure-apns
categorySlug: integrations
parentDocSlug: ios-sdk-push-notifications
---

Чтобы иметь возможность отправлять [iOS push-уведомления](https://documentation.bloomreach.com/engagement/docs/ios-sdk-push-notifications) с помощью Engagement, вы должны получить ключ подписи токена аутентификации Apple Push Notification service (APNs) и настроить интеграцию APNs в веб-приложении Engagement.

> 📘
>
> Обратитесь к [документации разработчика Apple Push Notifications](https://developer.apple.com/documentation/usernotifications) для получения подробностей.

## Получение ключа APNs

1. В вашей [учетной записи разработчика Apple](https://developer.apple.com/account/resources/authkeys/list) перейдите в `Certificates, Identifiers & Profiles` > `Keys`.
![Apple Developer - ключи APNs](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/apns1.png)

2. Добавьте новый ключ и выберите APNs.
![Apple Developer - регистрация нового ключа APNs](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/apns2.png)

3. Подтвердите создание ключа. Нажмите `Download`, чтобы сгенерировать и скачать ключ. Запомните `Team id` (в правом верхнем углу) и `Key Id`.
![Apple Developer - скачивание ключа APNs](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/apns3.png)

> ❗️
>
> Обязательно сохраните скачанный ключ в безопасном месте, так как вы не сможете скачать его повторно.

## Добавление ключа APNs в Engagement

1. Откройте веб-приложение Engagement и перейдите в `Data & Assets` > `Integrations`. Нажмите `+ Add new integration`.
![Engagement Integrations - Добавление новой интеграции](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/apns4.png)

2. Найдите `Apple Push Notification Service` и нажмите `+ Add integration`.
![Engagement Integrations - Выбор интеграции Apple Push Notification Service](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/apns5.png)

3. Прочитайте и примите условия использования.
![Engagement Integrations - Принятие условий использования](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/apns6.png)

4. Выберите `API mode` (`Development` или `Production`) и введите `Team ID` и `Key ID`. Откройте скачанный файл ключа в текстовом редакторе и скопируйте его содержимое в поле `ES256 Private Key`. Введите `Bundle ID` вашего приложения. Нажмите `Save integration` для завершения.
![Engagement Integrations - Настройка интеграции APNs](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/apns7.png)
   > ❗️
   >
   > Среда API (`Development` или `Production`) не может быть изменена позже. Вам нужно создать новую интеграцию, если вы хотите использовать другую среду. Если возникают ошибки BadDeviceToken, убедитесь, что выбрана правильная среда API.
   
   > ❗️
   >
   > Только одна интеграция APNs может быть активна одновременно в проекте Engagement. Если вы хотите использовать среды разработки и продакшена APNs одновременно, вам нужны два отдельных проекта Engagement.

   > ❗️
   >
   > Убедитесь, что `Application Bundle ID` соответствует `Bundle Identifier` в целевом приложении в Xcode. Если они не совпадают, push-уведомления не будут доставлены.


5. Перейдите в `Settings` > `Project settings` > `Channels` > `Push notifications` > `iOS Notification` и установите `Apple Push Notification Service integration` в `Apple Push Notification Service`.
![Engagement - Выбор интеграции APNs](https://raw.githubusercontent.com/exponea/exponea-ios-sdk/main/Documentation/images/apns8.png)