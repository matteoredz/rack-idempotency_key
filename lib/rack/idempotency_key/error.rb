# frozen_string_literal: true

module Rack
  class IdempotencyKey
    # Base error class for all IdempotencyKey errors
    Error = Class.new(StandardError)

    class IdempotentRequest
      # Error raised for general idempotent request failures
      Error = Class.new(Error)
      # Error raised when a conflicting idempotent request is detected
      ConflictError = Class.new(Error)
    end
  end
end
