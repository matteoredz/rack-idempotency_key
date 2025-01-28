# frozen_string_literal: true

module Rack
  class IdempotencyKey
    class IdempotentRequest
      # @param request [Rack::Request]
      # @param routes  [Array]
      # @param store   [Store]
      def initialize(request, routes, store)
        @request = request
        @routes  = routes
        @store   = store
      end

      # Checks if the `Idempotency-Key` header is present, if the HTTP request method is
      # allowed and if there is any matching route whitelisted in the `routes` array.
      #
      # @return [Boolean]
      def allowed?
        idempotency_key? && allowed_method? && any_matching_route?
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

      def cached_response
        store.get(cache_key).tap do |response|
          response[1]["Idempotent-Replayed"] = true unless response.nil?
        end
      end

      def cache(response)
        status, = response
        store.set(cache_key, response) if status != 400
      end

      # Checks if the HTTP request method is non-idempotent by design.
      #
      # @return [Boolean]
      def allowed_method?
        %w[POST PATCH CONNECT].include? request.request_method
      end

      # Checks if there is any matching route from the `routes` input array against
      # the currently requested path.
      #
      # @return [Boolean]
      def any_matching_route?
        routes.any? { |route| matching_route?(route[:path]) && matching_method?(route[:method]) }
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

        attr_reader :request, :routes, :store

        def matching_route?(route_path)
          route_segments = segments route_path
          path_segments.size == route_segments.size && same_segments?(route_segments)
        end

        def matching_method?(route_method)
          request.request_method.casecmp(route_method).zero?
        end

        def path_segments
          @path_segments ||= segments(request.path_info)
        end

        def segments(path)
          path.split("/").reject(&:empty?)
        end

        def same_segments?(route_segments)
          path_segments.each_with_index do |path_segment, index|
            route_segment = Regexp.new route_segments[index].gsub("*", '\w+'), Regexp::IGNORECASE
            return false unless path_segment.match?(route_segment)
          end

          true
        end
    end
  end
end
