#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#


Pod::Spec.new do |s|
  s.name             = 'flutter_live'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'



  s.static_framework = true
  s.resources = 'Classes/resource.bundle'
  s.dependency 'Flutter'
  s.dependency 'BJLiveUI', '~> 2.2.0'
  s.dependency 'BJPlaybackUI', '~> 2.2.0'
  #s.dependency 'BJVideoPlayerUI/static.source','~> 2.2.0'

  s.ios.deployment_target = '9.0'

 s.resource_bundles = {
        'BJVideoPlayerUI' => ['Classes/BJVideoPlayerUI/Assets/*.png']
      }

end

