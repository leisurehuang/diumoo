#source 'https://github.com/Cocoapods/Specs.git'

platform :osx, '10.10'
inhibit_all_warnings!

target 'diumoo' do
  pod 'MASShortcut', '~> 2.3.6'
  # Note: SMTabBar and SPMediaKeyTap don't have official CocoaPods specs
  # Their GitHub repos don't contain podspec files
  # Keeping local paths as there are no maintained CocoaPods alternatives
  # with Objective-C/macOS compatibility
  pod 'SMTabBar', :path => './third-party/SMTabBar'
  pod 'SPMediaKeyTap', :path => './third-party/SPMediaKeyTap'
end
