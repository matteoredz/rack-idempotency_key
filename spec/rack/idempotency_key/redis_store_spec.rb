# frozen_string_literal: true

require "mock_redis"
require "securerandom"
require "spec_helper"

RSpec.describe Rack::IdempotencyKey::RedisStore do
  subject(:store) { described_class.new(MockRedis.new) }

  include_examples "describe store get and set methods"
end
