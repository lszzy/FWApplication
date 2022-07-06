Pod::Spec.new do |s|
  s.name                  = 'FWApplication'
  s.version               = '3.5.1'
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
    ss.source_files = 'FWApplication/Classes/FWApplication/**/*.{h,m}'
    ss.library = 'sqlite3'
    ss.dependency 'FWFramework', "~> 3.5.0"
  end

  s.subspec 'Compatible' do |ss|
    ss.source_files = 'FWApplication/Classes/Compatible/**/*.swift'
    ss.dependency 'FWApplication/FWApplication'
    ss.pod_target_xcconfig = {
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => '$(inherited)'
    }
  end

  s.subspec 'SDWebImage' do |ss|
    ss.source_files = 'FWApplication/Classes/SDWebImage/**/*.{h,m,swift}'
    ss.dependency 'SDWebImage'
    ss.dependency 'FWApplication/FWApplication'
  end

  s.subspec 'SQLCipher' do |ss|
    ss.dependency 'SQLCipher'
    ss.dependency 'FWApplication/FWApplication'
    ss.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DSQLITE_HAS_CODEC -DHAVE_USLEEP=1' }
  end
end
