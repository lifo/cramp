Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'cramp'
  s.version = '0.13'
  s.summary = 'Asynchronous web framework.'
  s.description = 'Cramp is a framework for developing asynchronous web applications.'

  s.author = 'Pratik Naik'
  s.email = 'pratiknaik@gmail.com'
  s.homepage = 'http://m.onkey.org'

  s.add_dependency('activesupport', '~> 3.0.9')
  s.add_dependency('rack',          '~> 1.2.1')
  s.add_dependency('eventmachine',  '~> 0.12.10')
  s.add_dependency('thor',          '~> 0.14.6')

  s.files = Dir['README', 'MIT-LICENSE', 'lib/**/*', 'bin/**/*']
  s.has_rdoc = false

  s.require_path = 'lib'

  s.bindir = 'bin'
  s.executables = ['cramp']
end
