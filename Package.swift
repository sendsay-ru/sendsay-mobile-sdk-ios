// swift-tools-version:5.9

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
            targets: ["SendsaySDKNotifications"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.7.6")
    ],
    targets: [
        // Main library
        .target(
            name: "SendsaySDK",
            dependencies: [
                "SendsaySDKShared",
                "SendsaySDKObjC",
                .product(
                    name: "SwiftSoup",
                    package: "SwiftSoup"
                )
            ],
            path: "SendsaySDK/SendsaySDK",
            exclude: ["Supporting Files/Info.plist"],
            resources: [
                .process("Supporting Files/PrivacyInfo.xcprivacy"),
                .process("Classes/Database/DatabaseModel.xcdatamodeld")
            ]
        ),
        // Notification extension library
        .target(
            name: "SendsaySDKNotifications",
            dependencies: ["SendsaySDKShared"],
            path: "SendsaySDK/SendsaySDK-Notifications",
            exclude: ["Supporting Files/Info.plist"],
            resources: [.process("Supporting Files/PrivacyInfo.xcprivacy")]
        ),
        // Code shared between SendsaySDK and SendsaySDK-Notifications
        .target(
            name: "SendsaySDKShared",
            dependencies: [
                .product(
                    name: "SwiftSoup",
                    package: "SwiftSoup"
                ),
            ],
            path: "SendsaySDK/SendsaySDKShared",
            exclude: ["Supporting Files/Info.plist"]
        ),
        // ObjC code required by main library
        .target(
            name: "SendsaySDKObjC",
            dependencies: [],
            path: "SendsaySDK/SendsaySDKObjC",
            exclude: ["Info.plist"],
            sources: ["objc_tryCatch.m"],
            publicHeadersPath: "."
        )
    ]
)
