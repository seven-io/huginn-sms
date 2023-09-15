lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "huginn_seven_agent"
  spec.version       = '0.1.0'
  spec.authors       = ["seven communications GmbH & Co. KG"]
  spec.email         = ["support@seven.io"]

  spec.summary       = %q{Send SMS from Huginn via https://www.seven.io.}
  spec.description   = %q{Send SMS from Huginn via https://www.seven.io.}
  spec.homepage      = "https://github.com/seven-io/huginn"

  spec.license       = "MIT"


  spec.files         = Dir['LICENSE', 'lib/**/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = Dir['spec/**/*.rb'].reject { |f| f[%r{^spec/huginn}] }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "huginn_agent", "~> 0.6.1"
end