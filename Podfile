platform :ios, '11.0'

def shared_pods
    pod 'ChallongeNetworking'
#    pod 'ChallongeNetworking', :path => '../ChallongeNetworking'
end

target 'Challonge' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Challonge
  shared_pods
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SnapKit'
end

target 'ChallongeTests' do
    shared_pods
end
