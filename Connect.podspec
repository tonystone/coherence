#
# Be sure to run `pod lib lint Connect.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Connect'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Connect.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.license          = 'Apache License, Version 2.0'
  s.homepage         = "https://github.com/tonystone/connect1"
  s.author           = { "Tony Stone" => "https://github.com/tonystone" }
  s.source           = { :git => 'https://github.com/tonystone/connect1.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Connect/**/*'
  s.public_header_files = 'Pod/*.h'

  s.dependency 'TraceLog/ObjC', '~> 1.0'

  s.frameworks = 'CoreData'
  s.libraries = 'xml2'

  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }

end
