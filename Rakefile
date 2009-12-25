require 'rake'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
Rake::Task['test'].comment = "Run model and controller tests"

namespace :test do
  Rake::TestTask.new(:controller) do |t|
    t.libs << "test"
    t.pattern = 'test/controller/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:controller'].comment = "Run controller tests"

  Rake::TestTask.new(:model) do |t|
    t.libs << "test"
    t.pattern = 'test/model/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:model'].comment = "Run model tests"
end

