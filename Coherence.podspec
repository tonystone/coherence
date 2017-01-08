#
# Be sure to run `pod lib lint Coherence.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Coherence"
  s.version          = "2.0.1"
  s.summary          = "Coherence"
  s.description      = <<-DESC
                       Coherence is a collection of base frameworks that help set the groundwork for module development.
                       DESC
  s.homepage         = "https://github.com/tonystone/coherence"
  s.license          = 'Apache License, Version 2.0'
  s.author           = "Tony Stone"
  s.source           = { :git => "https://github.com/tonystone/coherence.git", :tag => s.version.to_s }

  s.platform      = :ios, '8.0'
  s.requires_arc  = true
  
  s.module_name   = 'Coherence'
  s.source_files  = 'Sources/**/*'
  s.exclude_files = 'Sources/ConfigurationCore/**/*'

  s.subspec 'No-Arc' do |sp|
    sp.requires_arc = false
    sp.source_files = 'Sources/ConfigurationCore/**/*'
  end

  s.dependency 'TraceLog', "~> 2.0"
  s.dependency 'TraceLog/ObjC', "~> 2.0"
end
