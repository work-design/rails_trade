$:.push File.expand_path('../lib', __FILE__)
require 'the_trade/version'

Gem::Specification.new do |s|
  s.name = 'the_trade'
  s.version = TheTrade::VERSION
  s.authors = ['qinmingyuan']
  s.email = ['mingyuan0715@foxmail.com']
  s.homepage = 'https://github.com/yigexiangfa/the_trade'
  s.summary = 'Summary of TheTrade.'
  s.description = 'Description of TheTrade.'
  s.license = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '>= 5.0.0'
  s.add_dependency 'jbuilder', '>= 2.7.0'
  s.add_dependency 'stripe'
  s.add_dependency 'money-rails', '~> 1.10.0'
end
