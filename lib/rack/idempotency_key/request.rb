# frozen_string_literal: true

module Rack
  class IdempotencyKey
    class Request
      # @param request [Rack::Request]
      # @param store   [Store]
      def initialize(request, store)
        @request = request
        @store   = store
      end

      # Checks if the `Idempotency-Key` header is present, if the HTTP request method is allowed.
      #
      # @return [Boolean]
      def allowed?
        idempotency_key? && allowed_method?
      end

      # TODO
      #
      # 1. Lock immediately the request using the store!
      #   1.1. Raise ConflictError if the execution should already be locked
      # 2. Yield the block
      # 3. Release the lock w/o affecting other locks
      def with_lock!
        yield
      end

      def cached_response!
        store.get(cache_key).tap do |response|
          response[1]["Idempotent-Replayed"] = true unless response.nil?
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

      def cache_key
        idempotency_key
      end

      private

        attr_reader :request, :store
    end
  end
end
