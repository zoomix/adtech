$: << File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'adtech'
  s.version     = '1.0.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['David Tollmyr']
  s.email       = ['david@burtcorp.com']
  s.homepage    = ''
  s.summary     = ''
  s.description = ''

  s.files         = `git ls-files`.split("\n")
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  # s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
