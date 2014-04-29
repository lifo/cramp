Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'cramp'
  s.version = '0.15.3'
  s.summary = 'Asynchronous web framework.'
  s.description = 'Cramp is a framework for developing asynchronous web applications.'

  s.author = ['Pratik Naik', 'Lucas Allan Amorim']
  s.email = ['pratiknaik@gmail.com', 'lucas.allan@gmail.com']
  s.homepage = 'http://cramp.in'
  s.license = 'MIT'

  s.add_dependency('activesupport',   '~> 3.2.16')
  s.add_dependency('rack',            '~> 1.5.2')
  s.add_dependency('eventmachine',    '~> 1.0.3')
  s.add_dependency('faye-websocket',  '~> 0.7.1')
  s.add_dependency('thor',            '~> 0.18.0')

  s.files = Dir['README', 'MIT-LICENSE', 'lib/**/*', 'bin/**/*']
  s.has_rdoc = false

  s.require_path = 'lib'

  s.bindir = 'bin'
  s.executables = ['cramp']
end
