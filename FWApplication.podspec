Pod::Spec.new do |s|
  s.name                  = 'FWApplication'
  s.version               = '3.0.0'
  s.summary               = 'ios application framework'
  s.homepage              = 'http://wuyong.site'
  s.license               = 'MIT'
  s.author                = { 'Wu Yong' => 'admin@wuyong.site' }
  s.source                = { :git => 'https://github.com/lszzy/FWApplication.git', :tag => s.version }

  s.ios.deployment_target = '11.0'
  s.swift_version         = '5.0'
  s.requires_arc          = true
  s.frameworks            = 'Foundation', 'UIKit'
  s.default_subspecs      = ['FWApplication', 'Compatible']

  s.subspec 'FWApplication' do |ss|
    # ss.resource_bundles = { 'FWApplication' => ['FWApplication/Assets/**/*.*'] }
    ss.dependency 'FWApplication/App'
    ss.dependency 'FWApplication/Controller'
    ss.dependency 'FWApplication/Model'
    ss.dependency 'FWApplication/Service'
    ss.dependency 'FWApplication/View'
  end
  
  s.subspec 'App' do |ss|
    ss.source_files = 'FWApplication/Classes/FWApplication/App/**/*.{h,m,swift}'
    ss.dependency 'FWFramework', "~> 3.0"
  end
  
  s.subspec 'Controller' do |ss|
    ss.source_files = 'FWApplication/Classes/FWApplication/Controller/**/*.{h,m,swift}'
    ss.dependency 'FWFramework', "~> 3.0"
    ss.dependency 'FWApplication/App'
  end
  
  s.subspec 'Model' do |ss|
    ss.source_files = 'FWApplication/Classes/FWApplication/Model/**/*.{h,m,swift}'
    ss.dependency 'FWFramework', "~> 3.0"
    ss.dependency 'FWApplication/App'
  end
  
  s.subspec 'Service' do |ss|
    ss.source_files = 'FWApplication/Classes/FWApplication/Service/**/*.{h,m,swift}'
    ss.library = 'sqlite3'
    ss.dependency 'FWFramework', "~> 3.0"
    ss.dependency 'FWApplication/App'
  end
  
  s.subspec 'View' do |ss|
    ss.source_files = 'FWApplication/Classes/FWApplication/View/**/*.{h,m,swift}'
    ss.dependency 'FWFramework', "~> 3.0"
    ss.dependency 'FWApplication/App'
  end

  s.subspec 'Compatible' do |ss|
    ss.source_files = 'FWApplication/Classes/Module/Compatible/**/*.{h,m,swift}'
    ss.dependency 'FWApplication/FWApplication'
  end

  s.subspec 'SDWebImage' do |ss|
    ss.source_files = 'FWApplication/Classes/Module/SDWebImage/**/*.{h,m,swift}'
    ss.dependency 'SDWebImage'
    ss.dependency 'FWApplication/FWApplication'
  end

  s.subspec 'SQLCipher' do |ss|
    ss.dependency 'SQLCipher'
    ss.dependency 'FWApplication/FWApplication'
    ss.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DSQLITE_HAS_CODEC -DHAVE_USLEEP=1' }
  end
end
