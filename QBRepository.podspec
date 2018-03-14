#
# Be sure to run `pod lib lint QBRepository.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QBRepository'
  s.version          = '0.1.0'
  s.summary          = 'QBRepository is a simple implementation of the repository pattern for data access in Swift.'

  s.description      = <<-DESC
QBRepository is a simple implementation of the repository pattern for data access in Swift, with a default wrapper for Realm und reactive extensions for RxSwift.
                       DESC

  s.homepage         = 'https://github.com/quickbirdstudios/QBRepository'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Stefan Kofler' => 'stefan.kofler@quickbirdstudios.com' }
  s.source           = { :git => 'https://github.com/quickbirdstudios/QBRepository.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.0'
  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'Sources/*.swift'
    ss.framework  = 'Foundation'
  end

  s.subspec 'Realm' do |ss|
    ss.source_files = 'Sources/Realm/*.swift'
    ss.dependency 'QBRepository/Core'
    ss.dependency 'RealmSwift', '~> 3.0'
  end

  s.subspec 'RxSwift' do |ss|
    ss.source_files = 'Sources/RxSwift/*.swift'
    ss.dependency 'QBRepository/Core'
    ss.dependency 'RxSwift', '~> 4.0'
  end

end
