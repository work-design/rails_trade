$:.push File.expand_path('lib', __dir__)
require 'rails_trade/version'

Gem::Specification.new do |s|
  s.name = 'rails_trade'
  s.version = RailsTrade::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/yougexiangfa/rails_trade'
  s.summary = "Summary of Rails Trade."
  s.description = "Description of TheSync."
  s.license = 'LGPL-3.0'

  s.files = Dir[
    '{app,config,db,lib}/**/*',
    'LICENSE',
    'Rakefile',
    'README.md'
  ]

  s.add_dependency 'rails', '~> 5.0'
  s.add_dependency 'money-rails', '~> 1.12'
  s.add_dependency 'default_where', '~> 2.2'
  s.add_dependency 'default_form', '~> 1.3'
  s.add_dependency 'rails_com', '~> 1.2'
  s.add_dependency 'rails_data', '~> 0'
  s.add_dependency 'rails_audit', '~> 1.0'
  s.add_dependency 'rails_role', '~> 1.0'
end
