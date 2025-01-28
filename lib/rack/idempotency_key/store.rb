# frozen_string_literal: true

module Rack
  class IdempotencyKey
    class Store
      def initialize(store, expires_in: 86_400)
        @store      = store
        @expires_in = expires_in
      end

      protected

        attr_reader :store, :expires_in
    end
  end
end
