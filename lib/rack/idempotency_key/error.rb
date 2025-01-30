# frozen_string_literal: true

module Rack
  class IdempotencyKey
    # Base error class for all IdempotencyKey errors
    Error = Class.new(StandardError)

    # Error raised when a conflicting idempotent request is detected
    class ConflictError < Error
      DEFAULT_MESSAGE = "This request is already being processed. Please retry later."

      def initialize(msg = DEFAULT_MESSAGE)
        super(msg)
      end
    end

    # Error raised for general store failures
    StoreError = Class.new(Error)
  end
end
