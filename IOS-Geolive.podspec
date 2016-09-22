#
# Be sure to run `pod lib lint IOS-Geolive.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "IOS-Geolive"
  s.version          = "0.1.0"
  s.summary          = "Geolive Framework"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
A collection of libraries for interacting with a Geolive Server, and display on a MKMap
                       DESC

  s.homepage         = "https://github.com/nickolanack/IOS-Geolive"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "nickolanack" => "nickblackwell82@gmail.com" }
  s.source           = { :git => "https://github.com/nickolanack/IOS-Geolive.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.1'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'IOS-Geolive' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'IOSQlite'
  # s.dependency 'IOSQlite', :path => '~/git/IOS-Pods/IOSQlite'
  # :git => 'https://github.com/nickolanack/IOSQLite.git', :branch => 'master'
end
