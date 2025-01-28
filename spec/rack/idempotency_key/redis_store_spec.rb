# frozen_string_literal: true

require "mock_redis"
require "securerandom"
require "spec_helper"

RSpec.describe Rack::IdempotencyKey::RedisStore do
  subject(:store) { described_class.new(redis_mock) }

  let(:redis_mock) { MockRedis.new }

  include_examples "describe store get and set methods"

  describe "a generic Redis error" do
    context "when the underlying redis store raises Redis::BaseError on get" do
      before { allow(redis_mock).to receive(:get).and_raise(Redis::BaseError) }

      it "raises a store error" do
        expect { store.get("key") }.to raise_error(Rack::IdempotencyKey::Store::Error)
      end
    end

    context "when the underlying redis store fails the setter" do
      before { allow(redis_mock).to receive(:set).and_raise(Redis::BaseError) }

      it "raises a store error" do
        expect { store.set("key", "val") }.to raise_error(Rack::IdempotencyKey::Store::Error)
      end
    end
  end
end
