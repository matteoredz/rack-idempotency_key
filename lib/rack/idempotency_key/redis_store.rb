# frozen_string_literal: true

require "redis"

require "rack/idempotency_key/store"

module Rack
  class IdempotencyKey
    class RedisStore < Store
      KEY_NAMESPACE = "idempotency_key"

      def get(key)
        value = with_redis { |redis| redis.get(namespaced_key(key)) }
        JSON.parse(value) unless value.nil?
      rescue Redis::BaseError => e
        raise Rack::IdempotencyKey::Store::Error, "#{self.class}: #{e.message}"
      end

      def set(key, value)
        with_redis { |redis| redis.set(namespaced_key(key), value, nx: true, ex: expires_in) }
        get(key)
      rescue Redis::BaseError => e
        raise Rack::IdempotencyKey::Store::Error, "#{self.class}: #{e.message}"
      end

      private

        # Executes the given block with a Redis connection, supporting both direct
        # Redis instances and connection pools (https://github.com/mperham/connection_pool).
        #
        # If a `ConnectionPool` is detected (by responding to `with`), it will yield a Redis
        # connection from the pool. Otherwise, it will yield the direct Redis instance.
        #
        # @yieldparam redis [Redis] A Redis connection instance.
        # @return [Object] The result of the block execution.
        #
        # @example Using a direct Redis instance
        #   store = RedisStore.new(Redis.new)
        #   store.with_redis { |redis| redis.set("key", "value") }
        #
        # @example Using a Redis connection pool
        #   store = RedisStore.new(ConnectionPool.new(size: 5, timeout: 5) { Redis.new })
        #   store.with_redis { |redis| redis.set("key", "value") }
        def with_redis(&block)
          if store.respond_to?(:with)
            store.with(&block)
          else
            yield store
          end
        end

        def namespaced_key(key)
          "#{KEY_NAMESPACE}:#{key.split.join}"
        end
    end
  end
end
