platform :osx,'10.12.2'

target 'Conferences' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for Conferences
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SwiftLint'
  pod 'RealmSwift', '~> 3.20.0'
  pod 'Kingfisher', '~> 5.0'
  pod 'TinyConstraints'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Sparkle'
  pod 'LetsMove'
  pod 'YoutubePlayer-in-WKWebView', :git => 'https://github.com/zagahr/YoutubePlayer-in-WKWebView.git', :branch=>'master'

  target 'ConferencesTests' do
      inherit! :search_paths
      pod 'RxTest'
      pod 'RxSwift'
      pod 'RxCocoa'
  end
  
end
