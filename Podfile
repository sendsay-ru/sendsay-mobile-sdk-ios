#!/usr/local/bin/ruby -w

project 'SendsaySDK/SendsaySDK.xcodeproj'

platform :ios, '13.0'

use_frameworks!
inhibit_all_warnings!

abstract_target 'SendsayDependencies' do

  pod 'SwiftSoup', '>= 2.7.6', '< 3.0'

  target 'SendsaySDK' do
  end

  target 'Example' do
      # Pods for UI
      pod 'DropDown'
      pod 'IQKeyboardManagerSwift'

      # Pods for Firebase
      pod 'Firebase/AnalyticsWithoutAdIdSupport'
      pod 'FirebaseCrashlytics'
      pod 'FirebaseMessaging'
  end
end

target 'SendsaySDKTests' do
    # Pods for testing
    pod 'Quick'
    pod 'Nimble', '~>9.2.0'
    pod 'Mockingjay',
        :git => 'https://github.com/kylef/Mockingjay.git',
        :branch => 'master'
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
