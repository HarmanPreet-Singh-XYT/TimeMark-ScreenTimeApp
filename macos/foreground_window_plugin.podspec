#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint foreground_window_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'foreground_window_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin to get foreground window information.'
  s.description      = <<-DESC
A Flutter plugin to get foreground window information on macOS.
                       DESC
  s.homepage         = 'https://timemark.harmanita.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'TimeMark' => 'timemark@harmanita.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.13'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
