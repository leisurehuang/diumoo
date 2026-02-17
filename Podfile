platform :osx, '10.10'
inhibit_all_warnings!

target 'diumoo' do
  pod 'MASShortcut', '~> 2.3.6'
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
  end
end
