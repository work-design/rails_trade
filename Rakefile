require 'bundler/setup'
require 'sdoc'
require 'rdoc/task'

RDoc::Task.new(:sdoc) do |rdoc|
  rdoc.rdoc_dir = 'docs'
  rdoc.title = 'RailsTrade'
  rdoc.options << '--format=sdoc'
  rdoc.template = 'rails'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path('test/dummy/Rakefile', __dir__)
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'

Bundler::GemHelper.install_tasks

