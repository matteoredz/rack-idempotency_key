# frozen_string_literal: true

module Rack
  class IdempotencyKey
    class IdempotentRequest
      # @param [Rack::Request] request
      # @param [Array]         routes
      def initialize(request, routes = [])
        @request = request
        @routes  = routes
      end

      # Check if the `Idempotency-Key` header is present, if the HTTP request method is
      # allowed and if there is any matching route whitelisted in the `routes` array.
      #
      # @return [Boolean]
      def allowed?
        idempotency_key? && allowed_method? && any_matching_route?
      end

      # Check if the HTTP request method is non-idempotent by design.
      #
      # @return [Boolean]
      def allowed_method?
        %w[POST PATCH CONNECT].include? request.request_method
      end

      # Check if there is any matching route from the `routes` input array against
      # the currently requested path.
      #
      # @return [Boolean]
      def any_matching_route?
        routes.any? { |route| matching_route?(route[:path]) && matching_method?(route[:method]) }
      end

      # Check if the given request has the Idempotency-Key header
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

        attr_reader :request, :routes

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
