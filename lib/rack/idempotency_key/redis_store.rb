# frozen_string_literal: true

require "redis"

require "rack/idempotency_key/store"

module Rack
  class IdempotencyKey
    class RedisStore < Store
      KEY_NAMESPACE = "idempotency_key"

      def initialize(store, expires_in: 86_400)
        super(store, expires_in: expires_in)
      end

      def get(key)
        value = store.get(namespaced_key(key))
        JSON.parse(value) unless value.nil?
      rescue Redis::BaseError => e
        raise Rack::IdempotencyKey::Store::Error, "#{self.class}: #{e.message}"
      end

      def set(key, value)
        store.set(namespaced_key(key), value, nx: true, ex: expires_in)
        get(key)
      rescue Redis::BaseError => e
        raise Rack::IdempotencyKey::Store::Error, "#{self.class}: #{e.message}"
      end

      private

        def namespaced_key(key)
          "#{KEY_NAMESPACE}:#{key.split.join}"
        end
    end
  end
end
