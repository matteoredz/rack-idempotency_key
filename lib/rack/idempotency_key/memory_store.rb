# frozen_string_literal: true

require "rack/idempotency_key/store"

module Rack
  class IdempotencyKey
    class MemoryStore < Store
      def initialize(store = {}, expires_in: 86_400)
        super(store, expires_in: expires_in)
        @mutex = Mutex.new
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

        attr_reader :mutex

        def expired?(added_at)
          Time.now.utc - added_at > expires_in
        end
    end
  end
end
