
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vue_rails/version"

Gem::Specification.new do |spec|
  spec.name          = "vue_rails"
  spec.version       = VueRails::VERSION
  spec.authors       = ["纪亚荣"]
  spec.email         = ["583255925@qq.com"]

  spec.summary       = 'Vue integration for Ruby on Rails'
  spec.description   = 'initialize Vue Components in Rails Views and server render'
  spec.homepage      = "https://github.com/jiyarong/vue_rails"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "vue_ujs"]

  spec.add_development_dependency 'bundler', '>= 1.2.2'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency 'rails', '>= 5.1'
  spec.add_development_dependency 'webpacker'
  spec.add_dependency 'execjs'
end
