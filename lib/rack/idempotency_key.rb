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
    def initialize(app, routes: [], store: MemoryStore.new)
      @app    = app
      @routes = routes
      @store  = store
    end

    def call(env)
      request = Request.new(Rack::Request.new(env), routes, store)
      return app.call(env) unless request.allowed?

      handle_request!(request, env)
    rescue Request::ConflictError
      [409, { "Content-Type" => "text/plain" }, ["Conflict"]]
    rescue Store::Error => e
      [503, { "Content-Type" => "text/plain" }, [e.message]]
    end

    private

      attr_reader :app, :store, :routes

      def handle_request!(request, env)
        request.with_lock! do
          cached_response = request.cached_response!
          return cached_response unless cached_response.nil?

          app.call(env).tap { |response| request.cache!(response) }
        end
      end
  end
end
