---
title: Настройка Apple Push Notification Service
excerpt: Настройка интеграции Apple Push Notification Service для Engagement
slug: ios-sdk-configure-apns
categorySlug: integrations
parentDocSlug: ios-sdk-push-notifications
---

Чтобы иметь возможность отправлять [iOS push-уведомления](https://documentation.bloomreach.com/engagement/docs/ios-sdk-push-notifications) через Engagement, получите ключ подписи токена Apple Push Notification service (APNs) и настройте интеграцию APNs в веб-приложении Engagement.

> 📘
>
> Подробнее — в [документации Apple Push Notifications](https://developer.apple.com/documentation/usernotifications).

## Получение ключа APNs

1. Войдите в свою [учётную запись разработчика Apple](https://developer.apple.com/account/resources/authkeys/list) и откройте раздел **Certificates, Identifiers & Profiles** > **Keys**.
![Apple Developer — ключи APNs](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/apns1.png)

2. Создайте новый ключ и выберите APNs.
![Apple Developer — регистрация нового ключа APNs](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/apns2.png)

3. Подтвердите создание ключа. Нажмите «Download», чтобы сгенерировать и скачать ключ. Запомните **Team id** (в правом верхнем углу) и **Key Id**.
![Apple Developer — скачивание ключа APNs](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/apns3.png)

> ❗️
>
> Скачайте ключ и сохраните его в безопасном месте — повторно скачать его невозможно.

## Добавление ключа APNs в Engagement

1. В веб-приложении Engagement перейдите в **Data & Assets** > **Integrations** и нажмите «+ Add new integration».
![Engagement Integrations — Добавление новой интеграции](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/apns4.png)

2. Выберите «Apple Push Notification Service» и нажмите «+ Add integration».
![Engagement Integrations — Выбор интеграции Apple Push Notification Service](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/apns5.png)

3. Ознакомьтесь с условиями использования и подтвердите согласие.
![Engagement Integrations — Принятие условий использования](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/apns6.png)

4. Выберите режим API — **Development** или **Production**. Укажите **Team ID** и **Key ID**, вставьте содержимое файла ключа в поле **ES256 Private Key** и добавьте `Bundle ID` вашего приложения. Нажмите «Save integration».
![Engagement Integrations — Настройка интеграции APNs](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/apns7.png)
   > ❗️
   >
   > Режим API (**Development** или **Production**) изменить нельзя. Чтобы использовать другой режим, создайте новую интеграцию. Если получаете ошибку **BadDeviceToken**, проверьте, что выбран правильный режим.
   
   > ❗️
   >
   > В проекте Engagement может быть активна только одна интеграция APNs. Чтобы использовать одновременно среды разработки и продакшена, настройте два отдельных проекта.

   > ❗️
   >
   > Убедитесь, что `Application Bundle ID` совпадает с `Bundle Identifier` в настройках приложения в Xcode — иначе push-уведомления не будут доставляться.


5. Перейдите в **Settings** > **Project settings** > **Channels** > **Push notifications** > **iOS Notification** выберите вашу интеграцию в поле **Apple Push Notification Service integration**.
![Engagement — Выбор интеграции APNs](https://raw.githubusercontent.com/sendsay/sendsay-ios-sdk/main/Documentation/images/apns8.png)