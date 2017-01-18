#
#  Be sure to run `pod spec lint xxx.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name                        = "WeatherKit"
  s.version                     = "0.0.1"
  s.summary                     = "This is a framework for Weather Sample"
  s.description                 = "xxx "
  s.homepage                    = "xxx "
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license                     = { :type => "MIT", :file => "LICENSE" }

  s.author                      = { "Vince Davis" => "Vince.Davis@me.com" }
  s.social_media_url            = "http://twitter.com/vincedavis"

  s.ios.deployment_target       = "10.0"
  s.osx.deployment_target       = "10.12"
  s.watchos.deployment_target   = "3.0"
  s.tvos.deployment_target      = "10.0"

  s.source                      = { :git => "https://github.com/vinced45/quick-build-kit-apple.git", :tag => s.version.to_s }

  s.source_files                = ["QuickBuildKit/**/*.{swift,h,m}"]
  s.watchos.exclude_files       = ["QuickBuildKit/Ads/*.{swift,h,m}", "QuickBuildKit/Bluetooth/*.{swift,h,m}", "QuickBuildKit/Photos/*.{swift,h,m}", "QuickBuildKit/Search/*.{swift,h,m}", "QuickBuildKit/Speech/*.{swift,h,m}", "QuickBuildKit/Sounds/*.{swift,h,m}", "QuickBuildKit/StoreKit/*.{swift,h,m}", "QuickBuildKit/Animations/*.{swift,h,m}", "QuickBuildKit/Controllers/*.{swift,h,m}"]
  s.watchos.resource_bundles    = { 'Main' => ["Watch/Main.storyboard"] }

  s.watchos.frameworks          = "CloudKit", "CoreLocation", "Foundation", "HealthKit", "MapKit", "PassKit"
  s.ios.frameworks              = "AudioToolbox", "AVFoundation", "CloudKit", "Contacts", "CoreBluetooth", "CoreLocation", "CoreSpotlight", "EventKit", "Foundation", "HealthKit", "MapKit", "MobileCoreServices", "PassKit", "Photos", "Speech", "UIKit", "UserNotifications", "WatchConnectivity"

  s.requires_arc                = true

  s.dependency                  'RealmSwift', '~> 2.0.0'

end
