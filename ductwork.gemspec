lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ductwork/version'

Gem::Specification.new do |spec|
  spec.name = 'ductwork'
  spec.version = Ductwork::VERSION
  spec.authors = ['Ben Williams']
  spec.email = ['8enwilliams@gmail.com']

  spec.summary = 'Cross platform FIFO pipe action'
  spec.homepage = 'https://benjineering.com'
  spec.license = 'MIT'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  #spec.metadata['source_code_uri'] = 'TODO: Put your gem's public repo URL here.'
  #spec.metadata['changelog_uri'] = 'TODO: Put your gem's CHANGELOG.md URL here.'

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject do |f| 
      f.match(%r{^(test|spec|features)/})
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions << 'ext/ductwork/extconf.rb'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'rake-compiler', '~> 1.0'
end
