Pod::Spec.new do |s|
  s.name           = "ObjectPool"
  s.platform       = :ios
  s.version        = "1.1.2"
  s.ios.deployment_target = "9.0"
  s.summary        = "A small swift helper class for using an ObjectPool"
  s.author         = { "Bas van Kuijck" => "bas@e-sites.nl" }
  s.license        = { :type => "MIT", :file => "LICENSE" }
  s.homepage       = "https://github.com/e-sites/#{s.name}"
  s.source         = { :git => "https://github.com/e-sites/#{s.name}.git", :tag => s.version.to_s }
  s.source_files   = 'Source/*.{swift,h}'
  s.requires_arc   = true
  s.frameworks    = 'Foundation'
  s.deprecated_in_favor_of = 'Oganesson'
end
