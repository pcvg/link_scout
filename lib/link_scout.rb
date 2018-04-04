require 'net/http'
require 'uri'

require "link_scout/version"
require "link_scout/errors"

module LinkScout

  DEFAULT_OPTIONS = {
    success: 200,
    limit: 10,
    follow: true
  }

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
    case true
    when single?(args)
      # run single
      @options = merge_defaults(args[1])
      @options[:url] = args[0]
      run_single
    when single_hash?(args)
      # run single
      @options = merge_defaults(args[0])
      run_single
    when multiple_with_shared_options?(args)
      # run multiple with shared options
      @options = merge_defaults(args[1])
      run_multiple_with_shared_options(args[0])
    when multiple?(args)
      run_multiple(args[0])
    else
      raise InvalidUsageError,  'Invalid usage of LinkScout::run; please check the Readme.md for further information'
    end
  end

  private

  def self.merge_defaults(options)
    return DEFAULT_OPTIONS unless options.is_a?(Hash)

    DEFAULT_OPTIONS.merge(options)
  end


  # Fetches uri_str and tries limit times in case of redirections.
  # @return response
  def self.fetch(uri_str, limit=nil)
    # set starting limit if limit is not set
    limit ||= @options[:limit].to_i

    raise RedirectLoopError, 'HTTP redirect too deep' if limit == 0

    url = URI.parse(uri_str)
    path = !url.path.empty? ? url.path : '/'
    req = Net::HTTP::Get.new(path)
    response = Net::HTTP.start(url.host, url.port) { |http| http.request(req) }

    @final_uri = uri_str
    case response
    when Net::HTTPRedirection
      return response unless follow_redirects?
      fetch(response['location'], limit - 1)
    else
      response
    end
  end

  def self.successfull_response?(response)
    status_code_success?(response) && \
    pattern_success?(response, :pattern) && \
    pattern_success?(response, :antipattern) && \
    target_success? && \
    deeplink_success?
  end

  def self.follow_redirects?
    @options[:follow] == true
  end

  def self.status_code_success?(response)
    [*@options[:success]].map(&:to_s).include?(response.code)
  end

  def self.target_success?
    return true if @options[:target].nil?
    @final_uri == @options[:target]
  end

  def self.deeplink_success?
    return true if @options[:deeplink_param].nil?
    uri = URI.parse(@options[:url])
    params = Rack::Utils.parse_nested_query(uri.query)
    @final_uri == params[@options[:deeplink_param]]
  end

  # checks if pattern is matched, in case of antipattern its a success if
  # the response does not match. In any case its a success if the pattern type
  # is not set
  #
  # @params response, type
  # @return Bool
  def self.pattern_success?(response, type)
    return true if @options[type].nil?
    success = @options[type].match?(response.body)

    return !success if type == :antipattern
    success
  end

  # Usage:
  # LinkScout::run(url, options)
  def self.single?(args)
    args[0].is_a?(String)
  end

  # Usage:
  # LinkScout::run(url: url)
  def self.single_hash?(args)
    args[0].is_a?(Hash) && !args[0][:url].nil?
  end

  # Usage:
  # LinkScout::run([url: url, url: url1], options)
  def self.multiple?(args)
    args[0].is_a?(Array)
  end

  # Usage:
  # LinkScout::run([url, url1], options)
  def self.multiple_with_shared_options?(args)
    args[0].is_a?(Array) && args[0].first.is_a?(String)
  end

  def self.run_single
    successfull_response?(fetch(@options[:url]))
  end

  def self.run_multiple sets
    sets.map do |set|
      @options = merge_defaults(set)
      [set[:url], run_single]
    end
  end

  def self.run_multiple_with_shared_options urls
    urls.map do |url|
      @options[:url] = url

      [url, run_single]
    end
  end
end

