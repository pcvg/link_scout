
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "link_scout/version"

Gem::Specification.new do |spec|
  spec.name          = "link_scout"
  spec.version       = LinkScout::VERSION
  spec.authors       = ["Mike Peuerböck", "Ain Tohvri"]
  spec.email         = ["mike.peuerboeck@savings-united.com", "ain.tohvri@savings-united.com"]
  spec.summary       = %q{LinkScout helps users to find broken links by analysing response code or body.}
  spec.homepage      = "https://github.com/pcvg/link_scout"
  spec.license       = "MIT"
  spec.description = <<description
    LinkScout helps users to find broken links by analysing response code or body.
description


  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", ">= 2.0.6", "< 2.3.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.3"
  spec.add_development_dependency "coveralls", "~> 0.8"
end
