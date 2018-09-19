$:.push File.expand_path('lib', __dir__)
require 'rails_trade/version'

Gem::Specification.new do |s|
  s.name = 'rails_trade'
  s.version = RailsTrade::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/yougexiangfa/rails_trade'
  s.summary = "Summary of TheSync."
  s.description = "Description of TheSync."
  s.license = "LGPL-3.0"

  s.files = Dir[
    "{app,config,db,lib}/**/*",
    "LICENSE",
    "Rakefile",
    "README.md"
  ]

  s.add_dependency 'rails', '~> 5.0'
end
