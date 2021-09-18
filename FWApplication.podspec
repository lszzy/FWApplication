Pod::Spec.new do |s|
  s.name                  = 'FWApplication'
  s.version               = '1.0.0'
  s.summary               = 'ios application framework'
  s.homepage              = 'http://wuyong.site'
  s.license               = 'MIT'
  s.author                = { 'Wu Yong' => 'admin@wuyong.site' }
  s.source                = { :git => 'https://github.com/lszzy/FWApplication.git', :tag => s.version }

  s.ios.deployment_target = '11.0'
  s.swift_version         = '5.0'
  s.requires_arc          = true
  s.frameworks            = 'Foundation', 'UIKit'
  s.default_subspecs      = 'FWApplication'

  s.subspec 'FWApplication' do |ss|
    ss.dependency 'FWApplication/Framework'
    ss.dependency 'FWApplication/Application'
    ss.dependency 'FWApplication/Component/Foundation'
    ss.dependency 'FWApplication/Component/UIKit'
    ss.dependency 'FWApplication/Component/Deprecated'
  end

  s.subspec 'Framework' do |ss|
    ss.source_files = 'FWApplication/Classes/FWApplication.h'
    
    ss.subspec 'Kernel' do |sss|
      sss.source_files = 'FWApplication/Classes/Framework/Kernel/**/*.{h,m,swift}'
    end
    
    ss.subspec 'Service' do |sss|
      sss.source_files = 'FWApplication/Classes/Framework/Service/**/*.{h,m,swift}'
      sss.dependency 'FWApplication/Framework/Kernel'
    end
    
    ss.subspec 'Toolkit' do |sss|
      sss.source_files = 'FWApplication/Classes/Framework/Toolkit/**/*.{h,m,swift}'
      sss.dependency 'FWApplication/Framework/Kernel'
    end
    
    ss.subspec 'Bundle' do |sss|
      sss.resource_bundles = { 'FWApplication' => ['FWApplication/Assets/**/*.*'] }
    end
  end

  s.subspec 'Application' do |ss|
    ss.dependency 'FWApplication/Framework'

    ss.subspec 'App' do |sss|
      sss.source_files = 'FWApplication/Classes/Application/App/App/**/*.{h,m,swift}'
    end
    
    ss.subspec 'Plugin' do |sss|
      sss.source_files = 'FWApplication/Classes/Application/App/Plugin/**/*.{h,m,swift}'
    end

    ss.subspec 'Controller' do |sss|
      sss.source_files = 'FWApplication/Classes/Application/Controller/**/*.{h,m,swift}'
      sss.dependency 'FWApplication/Application/Plugin'
    end

    ss.subspec 'Model' do |sss|
      sss.source_files = 'FWApplication/Classes/Application/Model/**/*.{h,m,swift}'
    end

    ss.subspec 'View' do |sss|
      sss.source_files = 'FWApplication/Classes/Application/View/**/*.{h,m,swift}'
    end

    ss.subspec 'Cache' do |sss|
      sss.library = 'sqlite3'
      sss.source_files = 'FWApplication/Classes/Application/Service/Cache/**/*.{h,m,swift}'
    end

    ss.subspec 'Database' do |sss|
      sss.library = 'sqlite3'
      sss.source_files = 'FWApplication/Classes/Application/Service/Database/**/*.{h,m,swift}'
    end

    ss.subspec 'Media' do |sss|
      sss.source_files = 'FWApplication/Classes/Application/Service/Media/**/*.{h,m,swift}'
      sss.dependency 'FWApplication/Application/Network'
    end

    ss.subspec 'Network' do |sss|
      sss.source_files = 'FWApplication/Classes/Application/Service/Network/**/*.{h,m,swift}'
    end

    ss.subspec 'Request' do |sss|
      sss.source_files = 'FWApplication/Classes/Application/Service/Request/**/*.{h,m,swift}'
      sss.dependency 'FWApplication/Application/Network'
    end

    ss.subspec 'Socket' do |sss|
      sss.source_files = 'FWApplication/Classes/Application/Service/Socket/**/*.{h,m,swift}'
    end
  end

  s.subspec 'Component' do |ss|
    ss.dependency 'FWApplication/Framework'

    ss.subspec 'Foundation' do |sss|
      sss.source_files = 'FWApplication/Classes/Component/Foundation/**/*.{h,m,swift}'
    end

    ss.subspec 'UIKit' do |sss|
      sss.source_files = 'FWApplication/Classes/Component/UIKit/**/*.{h,m,swift}'
      sss.dependency 'FWApplication/Application/Plugin'
    end

    ss.subspec 'SwiftUI' do |sss|
      sss.source_files = 'FWApplication/Classes/Component/SwiftUI/**/*.{h,m,swift}'
    end
    
    ss.subspec 'Deprecated' do |sss|
      sss.source_files = 'FWApplication/Classes/Component/Deprecated/**/*.{h,m,swift}'
      sss.dependency 'FWApplication/Application/Plugin'
    end

    ss.subspec 'Contacts' do |sss|
      sss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'FWCOMPONENT_CONTACTS_ENABLED=1' }
    end

    ss.subspec 'Microphone' do |sss|
      sss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'FWCOMPONENT_MICROPHONE_ENABLED=1' }
    end

    ss.subspec 'Calendar' do |sss|
      sss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'FWCOMPONENT_CALENDAR_ENABLED=1' }
    end

    ss.subspec 'AppleMusic' do |sss|
      sss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'FWCOMPONENT_APPLEMUSIC_ENABLED=1' }
    end

    ss.subspec 'Tracking' do |sss|
      sss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'FWCOMPONENT_TRACKING_ENABLED=1' }
    end

    ss.subspec 'SDWebImage' do |sss|
      sss.dependency 'SDWebImage'
      sss.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'FWCOMPONENT_SDWEBIMAGE_ENABLED=1' }
    end

    ss.subspec 'SQLCipher' do |sss|
      sss.dependency 'SQLCipher'
      sss.dependency 'FWApplication/Application/Database'
      sss.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DSQLITE_HAS_CODEC -DHAVE_USLEEP=1' }
    end
  end
end
