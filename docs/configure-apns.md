---
title: Настройка Apple Push Notification Service
excerpt: Настройка интеграции Apple Push Notification Service для CDP Sendsay
slug: ios-sdk-configure-apns
categorySlug: integrations
parentDocSlug: ios-sdk-push-notifications
---

Чтобы иметь возможность отправлять [iOS push-уведомления](../docs/push-notifications.md) через CDP Sendsay, получите ключ подписи токена Apple Push Notification service (APNs) и настройте интеграцию APNs в веб-приложении CDP Sendsay.

> 📘
>
> Подробнее — в [документации Apple Push Notifications](https://developer.apple.com/documentation/usernotifications).

## Получение ключа APNs

1. Войдите в свою [учётную запись разработчика Apple](https://developer.apple.com/account/resources/authkeys/list) и откройте раздел **Certificates, Identifiers & Profiles** > **Keys**.

   ![Apple Developer — ключи APNs](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-ios/main/docs/img/apns1.png)

2. Создайте новый ключ и выберите APNs.

   ![Apple Developer — регистрация нового ключа APNs](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-ios/main/docs/img/apns2.png)

3. Подтвердите создание ключа. Нажмите «Download», чтобы сгенерировать и скачать ключ. Запомните **Team id** (в правом верхнем углу) и **Key Id**.

   ![Apple Developer — скачивание ключа APNs](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-ios/main/docs/img/apns3.png)

> ❗️
>
> Скачайте ключ и сохраните его в безопасном месте — повторно скачать его невозможно.

## Добавление ключа APNs в CDP Sendsay

1. Откройте веб-приложение CDP Sendsay и перейдите в **Подписчики** > **Мобильное приложение**. Нажмите **+ Добавить приложение**. И введите название вашего приложения. Нажмите **Продолжить**.
   
2. Зайдите в созданное приложение в списке.  Вкладка **Настройки приложения и импорта** и нажмите **Подключить** напротив **APNs**.

   ![Sendsay Integrations - Выбор интеграции Apple Push Notification Service](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-ios/main/docs/img/sendsay-apns-1.png)

3. Введите **AppID** также как в xCode в графе **bundle identifier**(или ID пакета в AppStoreConnect). Откройте скачанный файл ключа в любом текстовом редакторе и скопируйте его содержимое в поле **Key**. Затем введите **Team ID** и **Key ID**. Выберите **Production** ли это версия (**false** - если еще тестируется и **true** - если это публичная версия), и наконец нажмите **Подключить** для завершения.

   ![Sendsay Integrations - Настройка интеграции APNs](https://raw.githubusercontent.com/sendsay-ru/sendsay-mobile-sdk-ios/main/docs/img/sendsay-apns-2.png)
   > ❗️
   >
   > Режим API (**Production** false или true) изменить нельзя. Чтобы использовать другой режим, создайте новую интеграцию. Если получаете ошибку **BadDeviceToken**, проверьте, что выбран правильный режим.
   
   > ❗️
   >
   > В проекте CDP Sendsay может быть активен только один тип окружения интеграции APNs. Чтобы использовать одновременно и окружение среды разработки и продакшена, настройте два отдельных проекта (в одном Production=false, в другом Production=true).

   > ❗️
   >
   > Убедитесь, что `Application Bundle ID` совпадает с `Bundle Identifier` в настройках приложения в Xcode — иначе push-уведомления не будут доставляться.
