# `Rack::IdempotencyKey`

> [!WARNING]
> This gem is in its pre-1.0 release phase, which means it may contain bugs and the API is subject to change.
> Proceed with caution and use it at your own risk.

A Rack Middleware implementing the idempotency design principle using the `Idempotency-Key` HTTP header. A cached response, generated by an idempotent request, can be recognized by checking for the presence of the `Idempotent-Replayed` response header.

## What is idempotency?

Idempotency is a design principle that allows a client to safely retry API requests that might have failed due to connection issues, without causing duplication or conflicts. In other words, no matter how many times you perform an idempotent operation, the end result will always be the same.

To be idempotent, only the state of the server is considered. The response returned by each request may differ: for example, the first call of a `DELETE` will likely return a `200`, while successive ones will likely return a `404`.

`POST`, `PATCH` and `CONNECT` are the non-idempotent methods, and this gem exists to make them so.

## Under the hood

- A valid idempotent request is cached on the server, using the `store` of choice
- A cached response expires out of the system after `5 minutes` by default
- A response with a `400` (BadRequest) HTTP status code isn't cached

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rack-idempotency_key"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rack-idempotency_key

## General usage

You may use this Rack Middleware in any application that conforms to the [Rack Specification](https://github.com/rack/rack/blob/main/SPEC.rdoc). Please refer to the specific application's guidelines.

## Usage with Rails

```ruby
# config/application.rb

module MyApp
  class Application < Rails::Application
    # ...

    config.middleware.use(
      Rack::IdempotencyKey,
      store: Rack::IdempotencyKey::MemoryStore.new
    )
  end
end
```

## Available Stores

The Store is responsible for getting and setting the response from a cache of a given idempotent request.

### MemoryStore

This one is the default store. It caches the response in memory.

```ruby
Rack::IdempotencyKey::MemoryStore.new

# Explicitly set the key's expiration, in seconds. The default is 300 (5 minutes)
Rack::IdempotencyKey::MemoryStore.new(expires_in: 300)
```

### RedisStore

This one is the suggested store to use in production. It relies on the [redis gem](https://github.com/redis/redis-rb).

```ruby
Rack::IdempotencyKey::RedisStore.new(Redis.current)

# Explicitly set the key's expiration, in seconds. The default is 300 (5 minutes)
Rack::IdempotencyKey::RedisStore.new(Redis.current, expires_in: 300)
```

If you're using a [Connection Pool](https://github.com/mperham/connection_pool), you can pass it instead of the single instance:

```ruby
redis_pool = ConnectionPool.new(size: 5, timeout: 5) { Redis.new }
Rack::IdempotencyKey::RedisStore.new(redis_pool)
```

### Custom Store

> [!IMPORTANT]
> Ensure proper concurrency handling when implementing a custom store to prevent race conditions and data inconsistencies.

Any object that conforms to the following interface can be used as a custom Store:

```ruby
# Gets the value by key from the store.
#
# @param key [String] The cache key
#
# @raise [Rack::IdempotencyKey::StoreError]
#   When the underlying store doesn't work as expected.
#
# @return [Array]
def get(key)

# Sets the value by key to the store.
#
# @param key [String] The cache key
# @param value [Array] The cache value
#
# @raise [Rack::IdempotencyKey::ConflictError]
#   When a concurrent request tries to update an already-cached request.
# @raise [Rack::IdempotencyKey::StoreError]
#   When the underlying store doesn't work as expected.
#
# @return [Array]
def set(key, value)

# Unsets the key/value pair from the store.
#
# @param key [String] The cache key
#
# @raise [Rack::IdempotencyKey::StoreError]
#   When the underlying store doesn't work as expected.
#
# @return [Array]
def unset(key)
```

The Array returned must conform to the [Rack Specification](https://github.com/rack/rack/blob/main/SPEC.rdoc), as follows:

```ruby
[
  200, # Response code
  {},  # Response headers
  []   # Response body
]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake test` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and tags,
and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/matteoredz/rack-idempotency_key.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [code of conduct](https://github.com/matteoredz/rack-idempotency_key/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the `Rack::IdempotencyKey` project's codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/matteoredz/rack-idempotency_key/blob/master/CODE_OF_CONDUCT.md).
