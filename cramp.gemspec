Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = 'cramp'
  s.version = '0.9'
  s.summary = "Async ORM and controller layer."
  s.description = <<-EOF
    Cramp provides ORM and controller layers for developing asynchronous web applications.
  EOF

  s.author = "Pratik Naik"
  s.email = "pratiknaik@gmail.com"
  s.homepage = "http://m.onkey.org"

  s.add_dependency('activesupport', '= 3.0.0.beta')
  s.add_dependency('activemodel',   '= 3.0.0.beta')
  s.add_dependency('arel',          '= 0.2.1')
  s.add_dependency('rack',          '~> 1.1.0')
  s.add_dependency('mysqlplus',     '~> 0.1.1')
  s.add_dependency('eventmachine',  '~> 0.12.10')

  s.files = Dir['README', 'MIT-LICENSE', 'lib/**/*']
  s.has_rdoc = false

  s.require_path = 'lib'
end
