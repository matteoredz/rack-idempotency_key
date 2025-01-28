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
      request = IdempotentRequest.new(Rack::Request.new(env), routes, store)
      return app.call(env) unless request.allowed?

      request.with_lock do
        return [409, { "Content-Type" => "text/plain" }, ["Conflict"]] if request.running?

        cached_response = request.cached_response
        return cached_response unless cached_response.nil?

        request.run
        app.call(env).tap { |response| request.cache(response) }
      end
    end

    private

      attr_reader :app, :store, :routes
  end
end
