# frozen_string_literal: true

require "mock_redis"
require "spec_helper"

RSpec.describe Rack::IdempotencyKey::RedisStore do
  subject(:store) { described_class.new(redis_mock) }

  let(:redis_mock) { MockRedis.new }

  include_examples "describe store get and set methods"

  describe "a generic Redis error" do
    context "when the underlying redis store raises Redis::BaseError on get" do
      before { allow(redis_mock).to receive(:get).and_raise(Redis::BaseError) }

      it "raises a store error" do
        expect { store.get("key") }.to raise_error(Rack::IdempotencyKey::StoreError)
      end
    end

    context "when the underlying redis store fails the setter" do
      before { allow(redis_mock).to receive(:set).and_raise(Redis::BaseError) }

      it "raises a store error" do
        expect { store.set("key", "val") }.to raise_error(Rack::IdempotencyKey::StoreError)
      end
    end
  end

  describe "#unset" do
    before { store.set("key", 1) }

    context "when successful" do
      it "removes the key/value pair from the store" do
        store.unset("key")
        expect(store.get("key")).to be_nil
      end
    end

    context "when the underlying redis store fails" do
      before { allow(redis_mock).to receive(:del).and_raise(Redis::BaseError) }

      it "raises a store error" do
        expect { store.unset("key") }.to raise_error(Rack::IdempotencyKey::StoreError)
      end
    end

    context "when the key doesn't exist" do
      it "doesn't raise an error" do
        expect { store.unset("non_existent_key") }.not_to raise_error
      end
    end

    context "with invalid input" do
      it "handles nil keys gracefully" do
        expect { store.unset(nil) }.not_to raise_error
      end
    end
  end
end
