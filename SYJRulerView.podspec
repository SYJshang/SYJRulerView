#
# Be sure to run `pod lib lint RulerKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SYJRulerView'
  s.version          = '1.0.1'
  s.summary          = 'swift of SYJRulerView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'The scale of iOS Ruler, including straight ruler and round ruler'

  s.homepage         = 'https://github.com/SYJshang/SYJRulerView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SYJshang' => '1334858022@qq.com' }
  s.source           = { :git => 'https://github.com/SYJshang/SYJRulerView.git', :tag => s.version.to_s }
  s.swift_versions = '4.0'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SYJRulerView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SYJRulerView' => ['SYJRulerView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
