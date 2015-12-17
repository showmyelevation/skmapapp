
Pod::Spec.new do |s|
  
  s.name         = 'ScoutMaps-iOS-SDKTools'
  s.version      = '2.2.0'
  s.license      = {:type => 'Commercial', :text =>'see http://www.skobbler.com/legal#termsSDK'}
  s.summary      = 'Utility library for the Scout Maps & Navigation SDK'
  s.description  = 'The utility library offers an out-of-the box Navigation UI for TBT navigation and advanced control over the experience of downloading maps'
  s.homepage     = 'http://developer.skobbler.com/getting-started/iosTools'
  s.author    	 = { 'Telenav Inc.' => 'http://www.telenav.com/about/' }
  s.platform     = :ios, '6.1'
  s.source       = {:http => 'http://developer.skobbler.com/cocoapods/ScoutMaps-iOS-SDKTools_2.2.0.zip'}

  non_arc_files = 'SDKTools/SDKTools/SKTDownloadManager/Helper/KVCBaseObject.{h,m}'

  s.subspec 'arc-files' do |arcfiles|
	arcfiles.source_files = 'SDKTools/**/*.{h,m,c}'
	arcfiles.prefix_header_file = 'SDKTools/SDKTools/SDKTools-Prefix.pch'
	arcfiles.exclude_files = 'SDKTools/SDKTools/SKTDownloadManager/Helper/KVCBaseObject.m'
	arcfiles.requires_arc = true
	
  end  

  s.subspec 'non-arc' do |narc|
	narc.source_files = non_arc_files
	narc.requires_arc = false
  end
  
  s.requires_arc = true
  s.resource  = 'SDKTools/SDKTools/Resources/SKTNavigationResources.bundle'
  s.frameworks = 'AVFoundation', 'CoreTelephony'
  s.documentation_url = 'http://developer.skobbler.com/getting-started/ios'
  s.dependency 'ScoutMaps-iOS-SDK', '~>2.2'
  s.xcconfig  =  { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/ScoutMaps-iOS-SDK/**"' }
  
end