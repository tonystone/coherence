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
  s.version          = "4.0.0-beta.1"
  s.summary          = "Coherence"
  s.description      = <<-DESC
                       Coherence is a collection of base frameworks that help set the groundwork for module development.
                       DESC
  s.homepage         = "https://github.com/tonystone/coherence"
  s.license          = 'Apache License, Version 2.0'
  s.author           = "Tony Stone"
  s.source           = { :git => "https://github.com/tonystone/coherence.git", :tag => s.version.to_s }

  s.ios.deployment_target     = '8.1'
  s.osx.deployment_target     = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'

  s.requires_arc  = true
  
  s.module_name   = 'Coherence'
  s.default_subspecs = ['Container', 'Connect']

  s.subspec 'CoreExtensions' do |sp|
    sp.source_files = 'Sources/CoreExtensions/**/*'
  end

  s.subspec 'Container' do |sp|
      sp.dependency 'Coherence/CoreExtensions'
      sp.source_files  = 'Sources/Container/*'
  end

  s.subspec 'Connect' do |sp|
      sp.dependency 'Coherence/CoreExtensions'
      sp.dependency 'Coherence/Container'
      sp.source_files  = 'Sources/Connect/**/*'
  end

  s.dependency 'TraceLog', "~> 3.0"
end
