# Uncomment this line to define a global platform for your project
platform :ios, ‘9.0’
# Uncomment this line if you're using Swift
 use_frameworks!

def shared_pods
    pod "youtube-ios-player-helper", "~> 0.1.4"
    pod 'ReachabilitySwift', git: 'https://github.com/ashleymills/Reachability.swift'
    pod "NMPopUpViewSwift"
    pod "DownPicker"
    pod 'CheckmarkSegmentedControl'
    pod 'Google/CloudMessaging'
    pod 'SwiftLoader'
end

target 'CruApp' do
    shared_pods
end

target 'CruAppTests' do
    shared_pods
end


