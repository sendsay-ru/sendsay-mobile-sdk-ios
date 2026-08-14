# Универсальные ссылки

Универсальные ссылки позволяют открывать ваше приложение напрямую по ссылкам, которые вы отправляете через CDP Sendsay. Пользователю не приходится проходить через промежуточные редиректы, а приложение получает возможность обработать ссылку и отследить переход.

Ниже описаны шаги, необходимые для включения и отслеживания универсальных ссылок с помощью iOS SDK.

## Включение универсальных ссылок

Чтобы поддерживать универсальные ссылки, приложение и ваш веб-сайт должны быть связаны между собой. Приложение должно объявить, какие URL оно может обрабатывать, а веб-сайт — подтвердить, что эти URL связаны с вашим приложением.

Следуйте инструкциям в документации Apple: [Supporting associated domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains).

### 1. Добавьте Associated Domains в Xcode

В Xcode откройте вкладку **Signing & Capabilities** таргета вашего приложения и добавьте [Associated Domains Entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_associated-domains) в **Associated Domains**:

  ```
  applinks:example.com
  webcredentials:example.com
  ```

### 2. Настройте файл apple-app-site-association на сайте

На вашем веб-сайте должен быть размещён файл **apple-app-site-association**, в котором перечислены идентификаторы приложений для вашего домена в сервисе `applinks`:

  ```
  {
    "applinks": {
      "apps": [],
      "details": [
        {
          "appID": "ABCDE12345.com.example.ExampleApp",
          "paths": [
            "/deeplink/*",
            "/*"
          ]
        }
      ]
    }
  }
  ```
  Файл должен быть доступен по адресу в формате:
  ```
  https://<домен>/.well-known/apple-app-site-association
  ```

После настройки связки между сайтом и приложением универсальные ссылки должны автоматически открывать ваше приложение.

> 👍
>
> Для тестирования отправьте себе письмо с универсальной ссылкой и откройте его из почтового клиента в веб-браузере.

Важно:
  - универсальные ссылки срабатывают только при переходе с другого домена; 
  - копирование и вставка URL в Safari **не работает**; 
  - переход по ссылке с того же домена или через JavaScript — тоже **не работает**.

## Отслеживание универсальных ссылок

Когда система открывает ваше приложение по универсальной ссылке, оно получает объект `NSUserActivity` со значением `activityType` равным `NSUserActivityTypeBrowsingWeb`. Вы должны обновить делегат вашего приложения, чтобы он отвечал и отслеживал ссылку, когда получает объект `NSUserActivity`.

Свойство `webpageURL` объекта activity содержит URL, который вам нужно передать в метод `.trackCampaignClick()` SDK.

Пример, как отвечать на универсальную ссылку и отслеживать ее:

```swift
func application(_ application:UIApplication,
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
        let incomingURL = userActivity.webpageURL
        else { return false }

    Sendsay.shared.trackCampaignClick(url: incomingURL, timestamp: nil)
    // обработать универсальную ссылку и вернуть true после её обработки
    return true
}
```
