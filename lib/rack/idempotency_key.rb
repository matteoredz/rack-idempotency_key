# frozen_string_literal: true

require "rack/idempotency_key/version"
require "rack/idempotency_key/error"

# Stores
require "rack/idempotency_key/memory_store"
require "rack/idempotency_key/redis_store"

# Collaborators
require "rack/idempotency_key/request"

module Rack
  class IdempotencyKey
    def initialize(app, store: MemoryStore.new)
      @app   = app
      @store = store
    end

    def call(env)
      request = Request.new(Rack::Request.new(env), store)
      return app.call(env) unless request.allowed?

      handle_request!(request, env)
    rescue ConflictError => e
      [409, { "Content-Type" => "text/plain" }, [e.message]]
    rescue StoreError => e
      [503, { "Content-Type" => "text/plain" }, [e.message]]
    end

    private

      attr_reader :app, :store

      def handle_request!(request, env)
        request.locked! do
          cached_response = request.cached_response!
          return cached_response unless cached_response.nil?

          app.call(env).tap { |response| request.cache!(response) }
        end
      end
  end
end
