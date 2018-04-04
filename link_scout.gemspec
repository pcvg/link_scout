
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "link_scout/version"

Gem::Specification.new do |spec|
  spec.name          = "link_scout"
  spec.version       = LinkScout::VERSION
  spec.authors       = ["Mike Peuerböck", "Ain Tohvri"]
  spec.email         = ["mike.peuerboeck@savings-united.com", "ain.tohvri@savings-united.com"]

  spec.summary       = %q{LinkScout is a tool to check if a given URL leads to a successfull response or not}
  spec.homepage      = "https://github.com/pcvg/link_scout"
  spec.license       = "MIT"
  spec.description = <<description
    LinkScout takes URLs and options as input and returns a boolean when URL leads to a successful response (true) or not (false).
    If an array of URLs is provided LinkScout returns the result as an Array like [[url, boolean],[url, boolena]]

    Example 1: Run a single URL
    LinkScout::run('http://url1.com?p=http://deeplink.com', success: [200, 201], follow: 1, deeplink_param: 'p', pattern: /Welcome/ig, antipattern: /Error/ig)

    Example 3: Run checks against multiple URLs with different options
    LinkScout::run(['http://url1.com', 'http://url2.com'], success: [200, 201])

    Example 2: Run checks against multiple URLs with different options
    LinkScout::run(
      {url: 'http://url1.com?p=http://deeplink.com'], success: [200, 201], deeplink_param: 'p'}
      {url: 'http://redirect.com'], success: 301}
    )

    Options:

    Expects options with the following keys:
    - url | URL - The URL to be checked ( only needed when multiple URLS with different options should be checked)
    - success | String, Array - (Default: 200) - Array of HTTP Status Codes that are considered as successfull, eg. 200,202
    - follow | Boolean (Default: true) - Follow all redirects and return checks only if the last response is successfull or not
    - limit | Integer (Default: 10) - Max. number of redirects to follow
    - target | URL - If provided check if the final response ended at the target url
    - deeplink_param | String - a param in the url that is considered to be the deeplink, if deeplink_param is found deeplink option is set automatically
    - pattern | Regex - Return "success" if a given pattern can be found on the response.body, e.g. /^my-pattern/ig
    - antipattern | Regex - Return "fail" if a given pattern can be found on the response.body, e.g. /^my-anti-pattern/ig
description

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "webmock", "~> 3.3"
end
