# frozen_string_literal: true

module Rack
  class IdempotencyKey
    class MemoryStore
      DEFAULT_EXPIRATION = 300 # 5 minutes in seconds

      def initialize(expires_in: DEFAULT_EXPIRATION)
        @store      = {}
        @expires_in = expires_in
        @mutex      = Mutex.new
      end

      def get(key)
        mutex.synchronize do
          value = store[key]
          return if value.nil?

          if expired?(value[:expires_at])
            store.delete(key)
            return
          end

          value[:value]
        end
      end

      def set(key, value, ttl: expires_in)
        mutex.synchronize do
          raise Rack::IdempotencyKey::ConflictError if store.key?(key)

          store[key] ||= { value: value, expires_at: Time.now.utc + ttl }
          store[key][:value]
        end
      end

      def unset(key)
        mutex.synchronize { store.delete(key) }
      end

      private

        attr_reader :store, :expires_in, :mutex

        def expired?(expires_at)
          Time.now.utc > expires_at
        end
    end
  end
end
