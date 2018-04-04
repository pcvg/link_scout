require 'net/http'
require 'uri'

require "link_scout/runner"
require "link_scout/version"
require "link_scout/errors"

module LinkScout
  # takes URLs and options as input and returns a boolean when URL leads to a successful response (true) or not (false).
  # If an array of URLs is provided LinkScout returns the result as an Array like [[url, boolean],[url, boolena]]
  #
  # Expects options with the following keys:
  # - url | URL - The URL to be checked ( only needed when multiple URLS with different options should be checked)
  # - success | String, Array - (Default: 200) - Array of HTTP Status Codes that are considered as successfull, eg. 200,202
  # - follow | Boolean (Default: true) - Follow all redirects and return checks only if the last response is successfull or not
  # - limit | Integer (Default: 10) - Max. number of redirects to follow
  # - target | URL - If provided check if the final response ended at the target url
  # - deeplink_param | String - a param in the url that is considered to be the deeplink, if deeplink_param is found deeplink option is set automatically
  # - pattern | Regex - Return "success" if a given pattern can be found on the response.body, e.g. /^my-pattern/ig
  # - antipattern | Regex - Return "fail" if a given pattern can be found on the response.body, e.g. /^my-anti-pattern/ig
  def self.run(*args)
    LinkScout::Runner.new().run(args)
  end
end

