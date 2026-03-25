#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint card_scanner.podspec' to validate before publishing.
#

Pod::Spec.new do |s|
  s.name             = 'card_scanner'
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
  s.resources = 'Assets/*.png'
  s.dependency 'Flutter'
  s.dependency 'GoogleMLKit/TextRecognition', '>= 6.0.0'
  s.platform = :ios, '15.0'
  s.static_framework = true

  # Flutter.framework supports both x86_64 and arm64 simulators.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
