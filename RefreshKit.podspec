Pod::Spec.new do |s|
  s.name         = "RefreshKit"
  s.version      = "1.1.0"
  s.summary      = "A custom pull to refresh and pagination library."
  s.description  = <<-DESC
                    RefreshKit is a custom library that provides custom pull to refresh and automatic pagination functionality for UIScrollView.
                    DESC
  s.homepage     = "https://github.com/atsed/RefreshKit"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.author       = { 'Egor Korotkii' => 'theatsed@gmail.com' }
  s.source       = { :git => 'https://github.com/atsed/RefreshKit.git', :tag => s.version.to_s }
  s.platform     = :ios, '12.0'
  s.source_files  = 'Sources/**/*.{swift}'
  s.swift_version = '5.0'
end
