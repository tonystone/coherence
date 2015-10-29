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
  s.version          = "0.3.0"
  s.summary          = "Coherence"
  s.description      = <<-DESC

                       DESC
  s.homepage         = "https://github.com/TheClimateCorporation/coherence"
  s.license          = 'Apache License, Version 2.0'
  s.author           = "Tony Stone"
  s.source           = { :git => "https://github.com/TheClimateCorporation/coherence.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.public_header_files = 'Pod/Classes/Coherence.h'
  s.source_files = 'Pod/Classes/Coherence.h'
  s.resource_bundles = {
    'Coherence' => ['Pod/Assets/*.png']
  }

  s.subspec 'Cache' do |sp|
     sp.source_files = 'Pod/Classes/Cache/*'

     sp.subspec 'Internal' do |sp|
        sp.source_files = 'Pod/Classes/Cache/Internal/**/*'
     end
  end

  s.subspec 'Utility' do |sp|
    sp.source_files = 'Pod/Classes/Utility/*'
  end

  s.subspec 'Configuration' do |sp|
    sp.source_files = 'Pod/Classes/Configuration/*'

    sp.dependency 'Coherence/Utility'
  end

  s.subspec 'Module' do |sp|
    sp.source_files = 'Pod/Classes/Module/*'
  end

  s.dependency 'TraceLog', "~>0.2"
end
