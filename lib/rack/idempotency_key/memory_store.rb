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

          if expired?(value[:added_at])
            store.delete(key)
            return
          end

          value[:value]
        end
      end

      def set(key, value)
        mutex.synchronize do
          store[key] ||= { value: value, added_at: Time.now.utc }
          store[key][:value]
        end
      end

      private

        attr_reader :store, :expires_in, :mutex

        def expired?(added_at)
          Time.now.utc - added_at > expires_in
        end
    end
  end
end
