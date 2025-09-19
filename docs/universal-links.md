#Универсальные ссылки

Универсальные ссылки позволяют ссылкам, которые вы отправляете через CDP Sendsay, открываться непосредственно в вашем мобильном приложении без каких-либо перенаправлений, которые могли бы помешать пользователям.

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
  https://<домен>/.well-known/apple-app-site-association
  ```

После того как указанные выше элементы установлены, открытие универсальных ссылок должно открывать ваше приложение.

> 👍
>
> Самый простой способ протестировать интеграцию - отправить себе электронное письмо, содержащее универсальную ссылку, и открыть его в вашем почтовом клиенте в веб-браузере. Универсальные ссылки работают правильно, когда пользователь нажимает или кликает по ссылке на другой домен. Копирование и вставка URL в Safari не работает, как и переход по ссылке на текущий домен или открытие URL с помощью Javascript.

## Отслеживание универсальных ссылок

Когда система открывает ваше приложение после того, как пользователь нажимает или кликает по универсальной ссылке, ваше приложение получает объект `NSUserActivity` со значением `activityType` равным `NSUserActivityTypeBrowsingWeb`. Вы должны обновить делегат вашего приложения, чтобы он отвечал и отслеживал ссылку, когда он получает объект `NSUserActivity`.

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
