# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
    
    target.build_configurations.each do |config|
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
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
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Google-Mobile-Ads-SDK'
  
  target  'SportsNoteTests' do
    inherit! :search_paths
  end

end
