#!/usr/local/bin/ruby -w
project 'SendsaySDK/SendsaySDK.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

use_frameworks!

target 'SendsaySDK' do
    pod 'SwiftSoup', '>= 2.7.6', '< 3.0'
end

target 'Example' do
    inherit! :search_paths

    inhibit_all_warnings!
    
    # Pods for UI
    pod 'DropDown'
    pod 'IQKeyboardManagerSwift'

    # Pods for Firebase
    pod 'Firebase/AnalyticsWithoutAdIdSupport'
    pod 'FirebaseCrashlytics'
    pod 'FirebaseMessaging'
end

target 'SendsaySDKTests' do
    inherit! :search_paths

    inhibit_all_warnings!

    # Pods for testing
    pod 'Quick'
    pod 'Nimble', '~>9.2.0'
    pod 'SwiftLint'
    pod 'Mockingjay', :git => 'https://github.com/kylef/Mockingjay.git', :branch => 'master'
end


post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
