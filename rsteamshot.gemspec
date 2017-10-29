# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rsteamshot/version'

Gem::Specification.new do |spec|
  spec.name          = 'rsteamshot'
  spec.version       = Rsteamshot::VERSION
  spec.authors       = ['Sarah Vessels']
  spec.email         = ['cheshire137@gmail.com']

  spec.summary       = %q{Get Steam screenshots for different games or users.}
  spec.description   = %q{Find screenshots publicly uploaded to Steam by a particular user or for a particular game. Get details like the title, how many likes and comments it has received, the dimensions and file size, and URLs for different sizes of each screenshot.}
  spec.homepage      = 'https://github.com/cheshire137/rsteamshot'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rdoc', '~> 5.1.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'vcr', '~> 3.0.3'
  spec.add_development_dependency 'webmock', '~> 3.1.0'

  spec.add_runtime_dependency 'mechanize', '~> 2.7.5'
end
