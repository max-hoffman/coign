# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'Coign' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Coign
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'FBSDKLoginKit'
  pod 'Firebase/Database'
  pod 'SkyFloatingLabelTextField', git: "https://github.com/MLSDev/SkyFloatingLabelTextField.git", branch: "swift3"
  pod 'IQKeyboardManagerSwift'
  pod 'GeoFire', :git => 'https://github.com/firebase/geofire-objc.git'
  
  
  # this was necessary to link the firebase database to geofire, copy pasted from the geofire github
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          if target.name == 'GeoFire' then
              target.build_configurations.each do |config|
                  config.build_settings['FRAMEWORK_SEARCH_PATHS'] = "#{config.build_settings['FRAMEWORK_SEARCH_PATHS']} ${PODS_ROOT}/FirebaseDatabase/Frameworks/ $PODS_CONFIGURATION_BUILD_DIR/GoogleToolboxForMac"
                  config.build_settings['OTHER_LDFLAGS'] = "#{config.build_settings['OTHER_LDFLAGS']} -framework FirebaseDatabase"
              end
          end
      end
  end
  
  target 'CoignTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CoignUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
