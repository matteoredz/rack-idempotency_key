# frozen_string_literal: true

require "rack/idempotency_key/version"

# Stores
require "rack/idempotency_key/memory_store"
require "rack/idempotency_key/redis_store"

# Collaborators
require "rack/idempotency_key/idempotent_request"

module Rack
  class IdempotencyKey
    Error = Class.new(StandardError)

    def initialize(app, routes: [], store: MemoryStore.new)
      @app    = app
      @routes = routes
      @store  = store
    end

    def call(env)
      request = IdempotentRequest.new(Rack::Request.new(env), routes)
      return app.call(env) unless request.allowed?

      cached_response = store.get(request.idempotency_key)

      if cached_response
        cached_response[1]["Idempotent-Replayed"] = true
        return cached_response
      end

      app.call(env).tap do |response|
        store.set(request.idempotency_key, response) if response[0] != 400
      end
    end

    private

      attr_reader :app, :store, :routes
  end
end
