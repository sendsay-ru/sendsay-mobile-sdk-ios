---
title: Универсальные ссылки
excerpt: Включение и отслеживание универсальных ссылок в вашем приложении с помощью iOS SDK
slug: ios-sdk-universal-links
categorySlug: integrations
parentDocSlug: ios-sdk
---

Универсальные ссылки позволяют ссылкам, которые вы отправляете через Engagement, открываться непосредственно в вашем нативном мобильном приложении без каких-либо перенаправлений, которые могли бы помешать пользователям.

Для получения подробностей о том, как работают универсальные ссылки и как они могут улучшить опыт ваших пользователей, обратитесь к разделу [Универсальные ссылки](https://documentation.bloomreach.com/engagement/docs/universal-link) в документации по кампаниям.

Эта страница описывает шаги, необходимые для поддержки и отслеживания входящих универсальных ссылок в вашем приложении с помощью iOS SDK.

## Включение универсальных ссылок

Для поддержки универсальных ссылок в вашем приложении вы должны создать двустороннюю связь между вашим приложением и вашим веб-сайтом и указать URL-адреса, которые обрабатывает ваше приложение.

Следуйте инструкциям в [Supporting associated domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains) в документации Apple Developer.

- Убедитесь, что вы добавили [Associated Domains Entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_associated-domains) в `Associated Domains` цели вашего приложения на вкладке `Signing & Capabilities`, например:
  ```
  applinks:example.com
  webcredentials:example.com
  ```
- Убедитесь, что вы настроили файл `apple-app-site-association` на вашем веб-сайте и что он перечисляет идентификаторы приложений для вашего домена в сервисе `applinks`. Например:
  ```
  {
    "applinks": {
      "apps": [],
      "details": [
        {
          "appID": "ABCDE12345.com.example.ExampleApp",
          "paths": [
            "/engagement/*",
            "/*"
          ]
        }
      ]
    }
  }
  ```
  Файл должен быть доступен по URL, соответствующему следующему формату.
  ```
  https://<полностью квалифицированный домен>/.well-known/apple-app-site-association
  ```

После того как указанные выше элементы установлены, открытие универсальных ссылок должно открывать ваше приложение.

> 👍
>
> Самый простой способ протестировать интеграцию - отправить себе электронное письмо, содержащее универсальную ссылку, и открыть его в вашем почтовом клиенте в веб-браузере. Универсальные ссылки работают правильно, когда пользователь нажимает или кликает по ссылке на другой домен. Копирование и вставка URL в Safari не работает, как и переход по ссылке на текущий домен или открытие URL с помощью Javascript.

## Отслеживание универсальных ссылок

Когда система открывает ваше приложение после того, как пользователь нажимает или кликает по универсальной ссылке, ваше приложение получает объект `NSUserActivity` со значением `activityType` равным `NSUserActivityTypeBrowsingWeb`. Вы должны обновить делегат вашего приложения, чтобы он отвечал и отслеживал ссылку на платформе Engagement, когда он получает объект `NSUserActivity`.

Свойство `webpageURL` объекта activity содержит URL, который вам нужно передать в метод `.trackCampaignClick()` SDK.

Пример кода ниже показывает, как отвечать на универсальную ссылку и отслеживать ее:

```swift
func application(_ application:UIApplication,
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
        let incomingURL = userActivity.webpageURL
        else { return false }

    Sendsay.shared.trackCampaignClick(url: incomingURL, timestamp: nil)
    // обработать универсальную ссылку и вернуть true после ее обработки
    return true
}
```

Параметры универсальной ссылки автоматически отслеживаются в событиях `session_start`, когда новая сессия запускается для данного клика по универсальной ссылке. Если URL содержит параметр `xnpe_cmp`, то отслеживается дополнительное событие `campaign`. Параметр `xnpe_cmp` представляет идентификатор кампании, обычно генерируемый для кампаний Email или SMS.

> ❗️
>
> Если существующая сессия возобновляется открытием универсальной ссылки, возобновленная сессия **НЕ** привязывается к клику по универсальной ссылке, и параметры клика по универсальной ссылке не отслеживаются в событии `session_start`. Поведение сессии определяется параметрами `automaticSessionTracking` и `sessionTimeout`, описанными в [конфигурации SDK](https://documentation.bloomreach.com/engagement/docs/ios-sdk-configuration). Пожалуйста, учитывайте это в случае ручной обработки сессий или при тестировании отслеживания универсальных ссылок во время разработки.

> ❗️
>
> SDK может не быть инициализирован, когда вызывается `.trackCampaignClick()`. В этом случае событие будет отправлено в бэкенд Engagement **после** [инициализации](https://documentation.bloomreach.com/engagement/docs/ios-sdk-setup#initialize-the-sdk) SDK с помощью `Sendsay.shared.configure()`.