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
  s.version          = "0.1.0"
  s.summary          = "Coherence - An offline caching synchronization library."
  s.description      = <<-DESC
                       Coherence is a library that allows offline use of a local CoreData cache.

                       It will keep the cache coherent between the master and slave caching local
                       changes until it can be synchronized with the master.
                       DESC
  s.homepage         = "https://www.climate.com"
  s.license          = 'MIT'
  s.author           = { "Tony Stone" => "tony@mobilegridinc.com" }
  s.source           = { :git => "ssh://git@stash.ci.climatedna.net:7999/fdi/coherence-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.public_header_files = 'Pod/Classes/Coherence.h'
  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Coherence' => ['Pod/Assets/*.png']
  }

  s.dependency 'TraceLog', ">=0.2.0"
end
