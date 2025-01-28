# frozen_string_literal: true

require "spec_helper"
require "rack/test"

RSpec.describe Rack::IdempotencyKey::Request do
  include Rack::Test::Methods

  subject(:request) { described_class.new(rack_request, routes, store) }

  let(:rack_request)    { Rack::Request.new(env) }
  let(:env)             { Rack::MockRequest.env_for(env_uri, env_opts) }
  let(:env_uri)         { "/" }
  let(:env_opts)        { {} }
  let(:routes)          { [] }
  let(:idempotency_key) { "123456789" }
  let(:store)           { Rack::IdempotencyKey::MemoryStore.new }

  shared_context "with idempotency key in place" do
    before { env["HTTP_IDEMPOTENCY_KEY"] = idempotency_key }
  end

  describe "#allowed?" do
    context "with idempotency key over an allowed method and a matching route" do
      include_context "with idempotency key in place"

      let(:env_opts) { { method: "POST" } }
      let(:env_uri)  { "/posts" }
      let(:routes)   { [{ path: "/posts", method: "POST" }] }

      it { is_expected.to be_allowed }
    end

    context "without the idempotency key" do
      let(:env_opts) { { method: "POST" } }
      let(:env_uri)  { "/posts" }
      let(:routes)   { [{ path: "/posts", method: "POST" }] }

      it { is_expected.not_to be_allowed }
    end

    context "with a not allowed request method" do
      include_context "with idempotency key in place"

      let(:env_uri) { "/posts" }
      let(:routes)  { [{ path: "/posts", method: "GET" }] }

      it { is_expected.not_to be_allowed }
    end

    context "without a matching route" do
      include_context "with idempotency key in place"

      let(:env_opts) { { method: "POST" } }
      let(:env_uri)  { "/posts/1/authors" }
      let(:routes)   { [{ path: "/posts/*", method: "POST" }] }

      it { is_expected.not_to be_allowed }
    end
  end

  describe "#allowed_method?" do
    %w[POST PATCH CONNECT].each do |request_method|
      context "when #{request_method}" do
        let(:env_opts) { { method: request_method } }

        it { is_expected.to be_allowed_method }
      end
    end

    %w[GET PUT OPTIONS].each do |request_method|
      context "when #{request_method}" do
        let(:env_opts) { { method: request_method } }

        it { is_expected.not_to be_allowed_method }
      end
    end
  end

  describe "#any_matching_route?" do
    context "without any declared route" do
      it { is_expected.not_to be_any_matching_route }
    end

    context "when the route ends with a placeholder" do
      let(:env_opts) { { method: "PATCH" } }
      let(:env_uri)  { "/posts/1" }
      let(:routes)   { [{ path: "/posts/*", method: "PATCH" }] }

      it { is_expected.to be_any_matching_route }
    end

    context "when the route ends with a defined character" do
      let(:env_opts) { { method: "POST" } }
      let(:env_uri)  { "/posts" }
      let(:routes)   { [{ path: "/posts", method: "POST" }] }

      it { is_expected.to be_any_matching_route }
    end

    context "with declared but no matching routes" do
      let(:env_opts) { { method: "POST" } }
      let(:env_uri)  { "/authors" }
      let(:routes)   { [{ path: "/posts/*/authors", method: "POST" }] }

      it { is_expected.not_to be_any_matching_route }
    end
  end

  describe "#idempotency_key?" do
    context "with the idempotency key" do
      include_context "with idempotency key in place"

      it { is_expected.to be_idempotency_key }
    end

    context "without the idempotency key" do
      it { is_expected.not_to be_idempotency_key }
    end
  end

  describe "#idempotency_key" do
    context "with the idempotency key" do
      include_context "with idempotency key in place"

      it { expect(request.idempotency_key).to eq(idempotency_key) }
    end

    context "without the idempotency key" do
      it { expect(request.idempotency_key).to be_nil }
    end
  end
end
