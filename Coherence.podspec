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
  s.version          = "0.2.4"
  s.summary          = "Coherence"
  s.description      = <<-DESC

                       DESC
  s.homepage         = "https://www.climate.com"
  s.license          = 'MIT'
  s.author           = { "Tony Stone" => "tony@mobilegridinc.com" }
  s.source           = { :git => "ssh://git@stash.ci.climatedna.net:7999/fdi/coherence-ios.git", :tag => s.version.to_s }

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

  s.subspec 'Configuration' do |sp|
    sp.source_files = 'Pod/Classes/Configuration/*'
  end

  s.subspec 'Module' do |sp|
    sp.source_files = 'Pod/Classes/Module/*'
  end

  s.subspec 'Utility' do |sp|
    sp.source_files = 'Pod/Classes/Utility/*'
  end

  s.dependency 'TraceLog', ">=0.2.0"
end
