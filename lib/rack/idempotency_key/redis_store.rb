# frozen_string_literal: true

module Rack
  class IdempotencyKey
    class RedisStore
      KEY_NAMESPACE = "idempotency_key"

      def initialize(store, expires_in: 86_400)
        @store      = store
        @expires_in = expires_in
      end

      def get(key)
        value = store.get(namespaced_key(key))
        JSON.parse(value) unless value.nil?
      end

      def set(key, value)
        store.set(namespaced_key(key), value, nx: true, ex: expires_in)
        get(key)
      end

      private

        attr_reader :store, :expires_in

        def namespaced_key(key)
          "#{KEY_NAMESPACE}:#{key.split.join}"
        end
    end
  end
end
