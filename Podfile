platform :ios, '11.0'

def shared_pods
    pod 'ChallongeNetworking', '0.4.0'
#    pod 'ChallongeNetworking', :path => '../ChallongeNetworking'
end

target 'Challonge' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Challonge
  shared_pods
  pod 'Fabric', '~> 1.8.2'
  pod 'Crashlytics', '~> 3.11.1'
  pod 'SnapKit', '~> 4.2.0'
end

target 'ChallongeTests' do
    shared_pods
end
