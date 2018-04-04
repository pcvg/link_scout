module LinkScout
  class Runner
    DEFAULT_OPTIONS = {
      success: 200,
      limit: 10,
      follow: true
    }

    def initialize args
      @args = args
    end

    def run
      case true
      when single?(@args)
        # run single
        @options = merge_defaults(@args[1])
        @options[:url] = @args[0]
        run_single
      when single_hash?(@args)
        # run single as hash
        @options = merge_defaults(@args[0])
        run_single
      when multiple_shared?(@args)
        # run multiple with shared options
        @options = merge_defaults(@args[1])
        run_multiple_shared(@args[0])
      when multiple_individual?(@args)
        # run multiple with individual options
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

    def successfull_response?(response)
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

    # checks if pattern is matched
    # - in case of pattern its a success if the response does match
    # - in case of antipattern its a success if the response does NOT match.
    # - In any case its a success if the pattern type is not set
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
      successfull_response?(fetch(@options[:url]))
    end

    def run_multiple sets
      sets.map do |set|
        @options = merge_defaults(set)
        [set[:url], run_single]
      end
    end

    def run_multiple_shared urls
      urls.map do |url|
        @options[:url] = url

        [url, run_single]
      end
    end
  end
end
