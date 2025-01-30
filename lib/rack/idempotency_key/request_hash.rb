# frozen_string_literal: true

require "digest"

module Rack
  class IdempotencyKey
    class RequestHash
      def initialize(rack_request)
        @rack_request = rack_request
      end

      # Generates a unique SHA-256 hash to identify the request.
      #
      # The hash is constructed using the request method, full path, idempotency key,
      # authorization header, and the request body (if available and rewindable).
      #
      # This ensures that requests with identical content produce the same fingerprint,
      # supporting idempotency while preventing accidental collisions between different clients.
      #
      # @return [String] A SHA-256 hexadecimal digest representing the request fingerprint.
      def id
        digest = Digest::SHA256.new
        digest.update(rack_request.request_method)
        digest.update(rack_request.fullpath)
        digest.update(idempotency_key_header)
        digest.update(authorization_header)
        update_with_request_body_chunks(digest)
        digest.hexdigest
      end

      private

        attr_reader :rack_request

        # Retrieves the `Idempotency-Key` header from the request. If the header is missing,
        # it defaults to `"no-idempotency-key"` to ensure that the request can still be processed
        # while clearly indicating the absence of an explicit idempotency key.
        def idempotency_key_header
          rack_request.get_header("HTTP_IDEMPOTENCY_KEY") || "no-idempotency-key"
        end

        # Retrieves the Authorization header from the request. If the header is missing,
        # defaults to "no-authorization" to indicate the absence of credentials.
        def authorization_header
          rack_request.get_header("HTTP_AUTHORIZATION") || "no-authorization"
        end

        # Updates the given digest with the request body content. If the body is non-rewindable
        # (e.g., a streaming request), it appends a predefined "streaming-body" marker instead.
        # Otherwise, it reads the body in 8KB chunks for efficient hashing and ensures the stream
        # is rewound after processing.
        #
        # @param digest [Digest::SHA256]
        def update_with_request_body_chunks(digest)
          return digest.update("streaming-body") unless rack_request.body.respond_to?(:rewind)

          begin
            while (chunk = rack_request.body.read(8192))
              digest.update(chunk)
            end
          ensure
            rack_request.body.rewind
          end
        end
    end
  end
end
