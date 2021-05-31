$:.push File.expand_path('lib', __dir__)
require 'rails_trade/version'

Gem::Specification.new do |s|
  s.name = 'rails_trade'
  s.version = RailsTrade::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/work-design/rails_trade'
  s.summary = 'Rails engine for trade, payment and more'
  s.description = 'trade, payment'
  s.license = 'MIT'

  s.files = Dir[
    '{app,config,db,lib}/**/*',
    'LICENSE',
    'Rakefile',
    'README.md'
  ]

  s.add_dependency 'rails_com', '~> 1.2'
  s.add_dependency 'money-rails', '~> 1.14'
  s.add_dependency 'rails_profile'
end
