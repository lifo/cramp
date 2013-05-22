# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cramp/version"

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'crampy'
  s.version = Cramp::VERSION
  s.summary = 'Asynchronous web framework.'
  s.description = 'Crampy is a fork of Cramp, a framework for developing asynchronous web applications.'

  s.authors = ['Pratik Naik', 'Vasily Fedoseyev']
  s.email = ['vasilyfedoseyev@gmail.com']
  s.homepage = 'https://github.com/Vasfed/cramp'

  # Not in a very distant future
  # s.required_ruby_version = '>=1.9.2'

  s.add_dependency('activesupport',   '~> 3.2')
  s.add_dependency('rack',            '~> 1.3')
  s.add_dependency('eventmachine',    '~> 1.0')
  s.add_dependency('faye-websocket',  '~> 0.3')
  s.add_dependency('thor',            '~> 0.14')

  s.files = Dir['README', 'MIT-LICENSE', 'lib/**/*', 'bin/**/*']
  s.has_rdoc = false

  s.require_path = 'lib'

  s.bindir = 'bin'
  s.executables = ['cramp']
end
