# frozen_string_literal: true

module Rack
  class IdempotencyKey
    Error = Class.new(StandardError)

    class IdempotentRequest
      Error = Class.new(Error)
      ConflictError = Class.new(Error)
    end
  end
end
