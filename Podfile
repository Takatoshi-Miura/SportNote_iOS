# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end

target '011-SportNote' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for 011-SportNote
  pod 'PKHUD'
  pod 'FSCalendar'
  pod 'CalculateCalendarLogic'
  pod 'RealmSwift'
  pod 'ReachabilitySwift'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'Firebase/Analytics'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Google-Mobile-Ads-SDK'

end
