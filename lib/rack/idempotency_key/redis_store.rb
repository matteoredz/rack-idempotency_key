# frozen_string_literal: true

require "redis"

module Rack
  class IdempotencyKey
    # Redis-based store for handling idempotency keys.
    #
    # This class provides methods to store, retrieve, and delete idempotency keys
    # in a Redis database, ensuring that the same request is not processed multiple
    # times. It supports both direct Redis instances and connection pools.
    #
    # @example Using a direct Redis instance
    #   redis = Redis.new
    #   store = Rack::IdempotencyKey::RedisStore.new(redis)
    #
    # @example Using a Redis connection pool
    #   redis_pool = ConnectionPool.new(size: 5, timeout: 5) { Redis.new }
    #   store = Rack::IdempotencyKey::RedisStore.new(redis_pool)
    class RedisStore
      DEFAULT_EXPIRATION = 300 # 5 minutes in seconds

      # Initializes a new RedisStore instance.
      #
      # @param store [Redis, ConnectionPool] A Redis instance or a connection pool.
      # @param expires_in [Integer] The default expiration time for stored values, in seconds.
      #
      # @example
      #   redis = Redis.new
      #   store = Rack::IdempotencyKey::RedisStore.new(redis, expires_in: 600)
      def initialize(store, expires_in: DEFAULT_EXPIRATION)
        @store      = store
        @expires_in = expires_in
      end

      # Retrieves a value from Redis by key.
      #
      # The stored value is expected to be JSON-encoded and is automatically parsed.
      # If the key does not exist, `nil` is returned.
      #
      # @param key [String] The Redis key to retrieve.
      # @return [Object, nil] The parsed JSON value, or `nil` if the key does not exist.
      #
      # @raise [Rack::IdempotencyKey::StoreError] If a Redis-related error occurs.
      #
      # @example Retrieve a value from Redis
      #   store.get("key") # => "value"
      def get(key)
        value = with_redis { |redis| redis.get(key) }
        JSON.parse(value) unless value.nil?
      rescue Redis::BaseError => e
        raise Rack::IdempotencyKey::StoreError, "#{self.class}: #{e.message}"
      end

      # Stores a value in Redis with an optional time-to-live (TTL).
      #
      # This method ensures that the key is only set if it does not already exist (`NX` flag).
      # If the key is already present, a `ConflictError` is raised.
      #
      # @param key [String] The Redis key to set.
      # @param value [String] The value to store.
      # @param ttl [Integer] The expiration time in seconds (defaults to `expires_in`).
      #
      # @return [Object, nil] The stored value retrieved from Redis.
      #
      # @raise [Rack::IdempotencyKey::ConflictError] If the key already exists and is locked.
      # @raise [Rack::IdempotencyKey::StoreError] If a Redis-related error occurs.
      #
      # @example Store a new idempotency key
      #   store.set("key", "value", ttl: 600)
      def set(key, value, ttl: expires_in)
        with_redis do |redis|
          result = redis.set(key, value, nx: true, ex: ttl)
          raise Rack::IdempotencyKey::ConflictError unless result
        end

        get(key)
      rescue Redis::BaseError => e
        raise Rack::IdempotencyKey::StoreError, "#{self.class}: #{e.message}"
      end

      # Deletes a key from Redis.
      #
      # This method removes the idempotency key from Redis, allowing the same request
      # to be processed again in the future.
      #
      # @param key [String] The Redis key to delete.
      #
      # @raise [Rack::IdempotencyKey::StoreError] If a Redis-related error occurs.
      #
      # @example Remove an idempotency key
      #   store.unset("key")
      def unset(key)
        with_redis { |redis| redis.del(key) }
      rescue Redis::BaseError => e
        raise Rack::IdempotencyKey::StoreError, "#{self.class}: #{e.message}"
      end

      private

        attr_reader :store, :expires_in

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
    end
  end
end
