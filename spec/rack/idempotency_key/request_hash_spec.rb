# frozen_string_literal: true

require "spec_helper"
require "rack/test"

require "digest"
require "stringio"

RSpec.describe Rack::IdempotencyKey::RequestHash do
  include Rack::Test::Methods

  subject(:request_hash) { described_class.new(rack_request) }

  let(:rack_request)    { Rack::Request.new(env) }
  let(:env)             { Rack::MockRequest.env_for(env_uri, env_opts) }
  let(:env_uri)         { "/" }
  let(:env_opts)        { {} }
  let(:idempotency_key) { "123456789" }
  let(:bearer_token)    { "Bearer token123" }

  shared_examples "a different id when the env changes" do
    let(:new_request)      { Rack::Request.new(new_env) }
    let(:new_request_hash) { described_class.new(new_request) }

    it { is_expected.not_to eq(new_request_hash.id) }
  end

  before do
    env["HTTP_IDEMPOTENCY_KEY"] = idempotency_key
    env["HTTP_AUTHORIZATION"]   = bearer_token
    env["rack.input"]           = StringIO.new("The request body")
  end

  describe "#id" do
    subject(:id) { request_hash.id }

    it "generates a consistent SHA-256 hash for the same request" do
      same_id_one = request_hash.id
      same_id_two = request_hash.id

      expect(same_id_one).to eq(same_id_two)
    end

    context "without the idempotency key header" do
      let(:constant_id) { "3d5b6059f39c534bd5731f870d2329287f12c4db44660573e89df794fd229de9" }

      before { env.delete("HTTP_IDEMPOTENCY_KEY") }

      it { is_expected.to eq(constant_id) }
    end

    context "without the authorization header" do
      let(:constant_id) { "596ec3d0f0735d982a8de4311141df0fdeea7c7bc4fdb71bce4a5342d65415df" }

      before { env.delete("HTTP_AUTHORIZATION") }

      it { is_expected.to eq(constant_id) }
    end

    context "without the request body" do
      let(:constant_id) { "15262d80b3fda7fb2ac47de1c9e6cf2ffa750e53fb72da593752163fed84c458" }

      before { env.delete("rack.input") }

      it { is_expected.to eq(constant_id) }
    end

    context "with a different request method" do
      let(:new_env) { env.merge("REQUEST_METHOD" => "POST") }

      include_examples "a different id when the env changes"
    end

    context "with a different request path" do
      let(:new_env) { env.merge("PATH_INFO" => "/api/other-resource") }

      include_examples "a different id when the env changes"
    end

    context "with a different idempotency key header" do
      let(:new_env) { env.merge("HTTP_IDEMPOTENCY_KEY" => "different-key") }

      include_examples "a different id when the env changes"
    end

    context "with a different authorization header" do
      let(:new_env) { env.merge("HTTP_AUTHORIZATION" => "Bearer another-token") }

      include_examples "a different id when the env changes"
    end

    context "with a different request body" do
      let(:new_env) { env.merge("rack.input" => StringIO.new("Another body")) }

      include_examples "a different id when the env changes"
    end
  end
end
