#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint app_device_integrity.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'app_device_integrity'
  s.version          = '0.0.2'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'app_device_integrity/Sources/app_device_integrity/**/*.swift'
  s.resource_bundles = {'app_device_integrity_privacy' => ['app_device_integrity/Sources/app_device_integrity/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '16.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
