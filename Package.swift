// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SendsaySDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SendsaySDK",
            targets: ["SendsaySDK"]),
        .library(
            name: "SendsaySDK-Notifications",
            targets: ["SendsaySDK-Notifications"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.1")
    ],
    targets: [
        // Main library
        .target(
            name: "SendsaySDK",
            dependencies: ["SendsaySDKShared", "SendsaySDKObjC"],
            path: "SendsaySDK/SendsaySDK",
            exclude: ["Supporting Files/Info.plist"],
            resources: [.copy("Supporting Files/PrivacyInfo.xcprivacy")]
        ),
        // Notification extension library
        .target(
            name: "SendsaySDK-Notifications",
            dependencies: ["SendsaySDKShared"],
            path: "SendsaySDK/SendsaySDK-Notifications",
            exclude: ["Supporting Files/Info.plist"],
            resources: [.copy("Supporting Files/PrivacyInfo.xcprivacy")]
        ),
        // Code shared between SendsaySDK and SendsaySDK-Notifications
        .target(
            name: "SendsaySDKShared",
            dependencies: ["SwiftSoup"],
            path: "SendsaySDK/SendsaySDKShared",
            exclude: ["Supporting Files/Info.plist"]
        ),
        // ObjC code required by main library
        .target(
            name: "SendsaySDKObjC",
            dependencies: [],
            path: "SendsaySDK/SendsaySDKObjC",
            exclude: ["Info.plist"],
            publicHeadersPath: ".")
    ]
)
