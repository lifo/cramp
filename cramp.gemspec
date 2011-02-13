Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'cramp'
  s.version = '0.12'
  s.summary = 'Asynchronous web framework.'
  s.description = 'Cramp is a framework for developing asynchronous web applications.'

  s.author = 'Pratik Naik'
  s.email = 'pratiknaik@gmail.com'
  s.homepage = 'http://m.onkey.org'

  s.add_dependency('activesupport', '~> 3.0.4')
  s.add_dependency('rack',          '~> 1.2.1')
  s.add_dependency('eventmachine',  '~> 0.12.10')

  s.files = Dir['README', 'MIT-LICENSE', 'lib/**/*']
  s.has_rdoc = false

  s.require_path = 'lib'
end
