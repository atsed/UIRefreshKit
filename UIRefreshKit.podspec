Pod::Spec.new do |s|
  s.name         = "UIRefreshKit"
  s.version      = "2.0.0"
  s.summary      = "A custom pull to refresh and pagination library."
  s.description  = <<-DESC
                    UIRefreshKit is a custom library that provides custom pull to refresh and automatic pagination functionality for UIScrollView.
                    DESC
  s.homepage     = "https://github.com/atsed/UIRefreshKit"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Egor Korotkii' => 'theatsed@gmail.com' }
  s.source       = { :git => 'https://github.com/atsed/UIRefreshKit.git', :tag => s.version.to_s }
  s.platform     = :ios, '12.0'
  s.source_files  = 'Sources/**/*.{swift}'
  s.swift_version = '5.0'
end