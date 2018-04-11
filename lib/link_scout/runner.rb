module LinkScout
  class Runner
    DEFAULT_OPTIONS = {
      success: 200,
      limit: 10,
      follow: true
    }

    def initialize(args)
      @args = args
    end

    def run
      case
      when single?(@args)
        @options = merge_defaults(@args[1])
        @options[:url] = @args[0]
        run_single
      when single_hash?(@args)
        @options = merge_defaults(@args[0])
        run_single
      when multiple_shared?(@args)
        @options = merge_defaults(@args[1])
        run_multiple_shared(@args[0])
      when multiple_individual?(@args)
        run_multiple(@args[0])
      else
        raise InvalidUsageError,  'Invalid usage of LinkScout::run. Please consult the README for help'
      end
    end

    private

    def merge_defaults(options)
      return DEFAULT_OPTIONS unless options.is_a?(Hash)

      DEFAULT_OPTIONS.merge(options)
    end

    # Fetches uri_str and tries limit times in case of redirections.
    # @return response
    def fetch(uri_str, limit=nil)
      # set starting limit if limit is not set
      limit ||= @options[:limit].to_i
      retry_count ||= 2

      # keeps track of previous url in case redirects are done
      @final_uri ||= nil

      raise RedirectLoopError, 'HTTP redirect too deep for ' + uri_str if limit == 0

      #uri_str = response['location']
      url = URI.parse(sanitize_uri(uri_str))
      req = Net::HTTP::Get.new(url, user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36')
      response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https', read_timeout: 30) { |http| http.request(req) }

      @final_uri = uri_str

      case response
      when Net::HTTPRedirection
        return response unless follow_redirects?
        fetch(response['location'], limit - 1)
      else
        response
      end

    rescue Errno::ETIMEDOUT
      [response, true]
    rescue Net::ReadTimeout => e
      retry_count -= 1
      p "Net::ReadTimeout - retry #{retry_count} fetch url " + uri_str and retry if retry_count > 0

      [response, true]
    rescue NoMethodError => e
      [response, true]
    rescue SocketError
      retry_count -= 1
      p "SocketError - retry #{retry_count} fetch url " + uri_str and retry if retry_count > 0

      [response, true]
    rescue URI::InvalidURIError
      [response, true]
    end

    def sanitize_uri(uri_str)
      return scheme_and_domain(@final_uri) if ['/', '//'].include? uri_str
      return scheme_and_domain(@final_uri) + uri_str if uri_str.start_with?('/')
      return scheme_and_domain(@final_uri) + uri_str if uri_str.start_with?('?')

      uri_str
    end

    def scheme_and_domain(uri_str)
      uri = URI.parse(uri_str)
      uri.path  = ''
      uri.query = nil

      # ensure that multiple relative redirects still know their domain
      if uri.to_s == ''
        return @last_scheme_and_domain
      end

      @last_scheme_and_domain = uri.to_s
    end

    def successfull_response?(response, invalid=false)
      !invalid && \
      status_code_success?(response) && \
      pattern_success?(response, :pattern) && \
      pattern_success?(response, :antipattern) && \
      target_success? && \
      deeplink_success?
    end

    def follow_redirects?
      @options[:follow] == true
    end

    def status_code_success?(response)
      [*@options[:success]].map(&:to_s).include?(response.code)
    end

    def target_success?
      return true if @options[:target].nil?
      @final_uri == @options[:target]
    end

    def deeplink_success?
      return true if @options[:deeplink_param].nil?
      uri = URI.parse(@options[:url])
      params = Rack::Utils.parse_nested_query(uri.query)
      @final_uri == params[@options[:deeplink_param]]
    end

    # checks response body against given pattern options:
    # - in any case its a success if the pattern type is not set
    # - in case of :pattern its a success if the content does match
    # - in case of :antipattern its a success if the content does NOT match.
    #
    # @params response, type
    # @return Bool
    def pattern_success?(response, type)
      return true if @options[type].nil?
      success = @options[type].match?(response.body)

      return !success if type == :antipattern
      success
    end

    # Usage:
    # LinkScout::run(url, options)
    def single?(args)
      args[0].is_a?(String)
    end

    # Usage:
    # LinkScout::run(url: url)
    def single_hash?(args)
      args[0].is_a?(Hash) && !args[0][:url].nil?
    end

    # Usage:
    # LinkScout::run([url: url, url: url1], options)
    def multiple_individual?(args)
      args[0].is_a?(Array) && args[0][0].is_a?(Hash)
    end

    # Usage:
    # LinkScout::run([url, url1], options)
    def multiple_shared?(args)
      args[0].is_a?(Array) && args[0].first.is_a?(String)
    end

    def run_single
      successfull_response?(*fetch(@options[:url]))
    end

    def run_multiple(sets)
      sets.map do |set|
        @options = merge_defaults(set)
        [set[:url], run_single]
      end
    end

    def run_multiple_shared(urls)
      urls.map do |url|
        @options[:url] = url

        [url, run_single]
      end
    end
  end
end
