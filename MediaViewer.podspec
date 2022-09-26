#
# Be sure to run `pod lib lint MediaViewer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MediaViewer'
  s.version          = '0.1.31'
  s.summary          = 'MediaViewer is used to open pdf documents and images.'

  s.description      = <<-DESC
'MediaViewer is used to open pdf documents and images, supports download.'
                       DESC

  s.homepage         = 'https://bitbucket.org/baianat/mediaviewer-ios.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'O-labib' => 'labib@baianat.com' }
  s.source           = { :git => 'https://bitbucket.org/baianat/mediaviewer-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
   
  s.source_files = 'MediaViewer/Classes/**/*'
  s.resources = 'MediaViewer/Assets/**/*'

  s.dependency 'Nuke'
end
