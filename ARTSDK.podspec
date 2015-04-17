Pod::Spec.new do |s|
  s.name         = 'ARTSDK'
  s.version      = '0.0.4'
  s.summary      = 'Art.com iOS SDK'
  s.author       = {
    'Doug Diego' => 'ddiego@art.com'
  }
  s.homepage = 'https://github.com/artcode/ARTSDK'
  s.source       = { :git => "https://github.com/artcode/ARTSDK.git", :tag => "0.0.4" }
  s.source_files = ['ARTSDK','thirdparty/nimbus/src/core/src', 'thirdparty/nimbus/src/networkimage/src','ARTSDK/CardIO']
  s.resource_bundles = { 'ArtAPI' => ['Resources/*.png', 'ARTSDK/*.xib','Resources/*.lproj','Resources/Fonts']}
  s.license		   = {
    :type => 'MIT',
    :file => 'LICENSE'
  }
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  #s.osx.deployment_target = '10.9'
  s.dependency 'AFNetworking', '~> 1.1.0'
  #s.dependency 'CardIO', '~> 3.4.4'
  s.dependency 'GoogleAnalytics-iOS-SDK', '~> 3.0.7'
  s.dependency 'SFHFKeychainUtils', '~> 0.0.1'
  s.dependency 'SVProgressHUD', '~> 0.8.1'
  s.dependency 'Facebook-iOS-SDK', '~> 3.16.0'
  s.dependency 'Pinterest-iOS', '~> 2.3'
  s.dependency 'PayPal-iOS-SDK', '~> 2.1'
  s.dependency 'Gigya-iOS-SDK'
end
