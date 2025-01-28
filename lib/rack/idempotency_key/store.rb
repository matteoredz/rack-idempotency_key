# frozen_string_literal: true

module Rack
  class IdempotencyKey
    class Store
      DEFAULT_EXPIRATION = 86_400 # 24 hours in seconds

      def initialize(store, expires_in: DEFAULT_EXPIRATION)
        @store      = store
        @expires_in = expires_in
      end

      protected

        attr_reader :store, :expires_in
    end
  end
end
