# frozen_string_literal: true

require "rack/idempotency_key/request_hash"

module Rack
  class IdempotencyKey
    class Request
      DEFAULT_LOCK_TTL = 60 # seconds

      # @param request [Rack::Request]
      # @param store   [Store]
      def initialize(request, store)
        @request    = request
        @request_id = Rack::IdempotencyKey::RequestHash.new(request).id
        @store      = store
      end

      # Checks if the `Idempotency-Key` header is present, if the HTTP request method is allowed.
      #
      # @return [Boolean]
      def allowed?
        idempotency_key? && allowed_method?
      end

      def cached_response!
        store.get(cache_key).tap do |response|
          response[1]["Idempotent-Replayed"] = true unless response.nil?
        end
      end

      def locked!
        store.set(lock_key, 1, ttl: DEFAULT_LOCK_TTL)

        begin
          yield
        ensure
          store.unset(lock_key)
        end
      end

      def cache!(response)
        status, = response
        store.set(cache_key, response) if status != 400
      end

      # Checks if the HTTP request method is non-idempotent by design.
      #
      # @return [Boolean]
      def allowed_method?
        %w[POST PATCH CONNECT].include? request.request_method
      end

      # Checks if the given request has the Idempotency-Key header
      #
      # @return [Boolean]
      def idempotency_key?
        request.has_header? "HTTP_IDEMPOTENCY_KEY"
      end

      # Fetches the Idempotency-Key header value from the request headers
      #
      # @return [String, nil]
      def idempotency_key
        request.get_header "HTTP_IDEMPOTENCY_KEY"
      end

      private

        attr_reader :request, :request_id, :store

        def cache_key
          "idempotency_key:#{request_id}"
        end

        def lock_key
          "#{cache_key}_lock"
        end
    end
  end
end
