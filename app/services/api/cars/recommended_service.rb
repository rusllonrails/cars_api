require 'circuitbox/faraday_middleware'

module Api
  module Cars
    # Service to get recommended cars list from Third-party API endpoint
    # https://bravado-images-production.s3.amazonaws.com/recomended_cars.json?user_id=<USER_ID>
    #
    # Logic of service:
    #
    # -> 1: return cached data if it was previously cached
    #
    # -> 2: do request to API if data is missing in cache
    #
    # -> 3: cache and return parsed data if response was valid
    #       or return fallback value if not
    #
    # Note 1: cache expiration period is 1 hour.
    #
    # Note 2: we are using the Circuit Breaker design pattern.
    #         It allows to prevent system from making unnecessary requests
    #         to external services when they are known to be failing.
    #
    #         Using a circuits defaults once more than 5 requests have been
    #         made with a 50% failure rate, Circuitbox stops sending requests
    #         to that failing service for 90 seconds.
    #
    #         Circuitbox will return nil for failed requests and open circuits.
    class RecommendedService
      CACHE_KEY_PREFIX = 'recommended_cars_for_user_'
      CACHE_EXPIRES_IN = 1.hour
      CIRCUIT_NAME = 'recommended_cars'
      FALLBACK_VALUE = [].freeze

      def initialize(user_id)
        @user_id = user_id
      end

      def call
        cached_data = Rails.cache.read(cache_key)
        return cached_data if cached_data

        result = Circuitbox.circuit(CIRCUIT_NAME, exceptions: [StandardError]).run do
          do_request
        end
        Rails.cache.write(cache_key, result, expires_in: CACHE_EXPIRES_IN) if result.present?

        result || FALLBACK_VALUE
      end

      private

      attr_reader :user_id

      def do_request
        response = connection.get('/recomended_cars.json', user_id:)

        begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          nil
        end
      end

      def cache_result
        Rails.cache.write(cache_key, expires_in: CACHE_EXPIRES_IN)
      end

      def cache_key
        "#{CACHE_KEY_PREFIX}#{user_id}"
      end

      def connection
        @connection ||= Faraday.new(url: Settings.recommendations_api.base_uri) do |conn|
          conn.use Circuitbox::FaradayMiddleware
          conn.request :json
          conn.response :raise_error
          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end
