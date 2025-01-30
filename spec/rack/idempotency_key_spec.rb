# frozen_string_literal: true

require "spec_helper"
require "rack/test"

RSpec.describe Rack::IdempotencyKey do
  include Rack::Test::Methods

  let(:app) { described_class.new(next_app, store: store) }
  let(:app_with_default_store) { described_class.new(next_app) }
  let(:next_app) { ->(_env = {}) { [200, { "Content-Type" => "text/plain" }, ["OK"]] } }
  let(:store) { described_class::MemoryStore.new }

  it "has a VERSION" do
    expect(Rack::IdempotencyKey::VERSION).to be_a(String)
  end

  it "has MemoryStore as default store" do
    expect(app_with_default_store.send(:store)).to be_a(Rack::IdempotencyKey::MemoryStore)
  end

  context "without Idempotency-Key header" do
    context "with an idempotent method" do
      before { get "/", {}, {} }

      it "responds with 200 HTTP status code" do
        expect(last_response.status).to eq(200)
      end

      it "responds with 'OK' plain text body" do
        expect(last_response.body).to eq("OK")
      end
    end

    context "with a non-idempotent method" do
      before { post "/", {}, {} }

      it "responds with 200 HTTP status code" do
        expect(last_response.status).to eq(200)
      end

      it "responds with 'OK' plain text body" do
        expect(last_response.body).to eq("OK")
      end
    end
  end

  context "with Idempotency-Key header and an idempotent method" do
    it "passes the env to the next Middleware" do
      allow(next_app).to receive(:call).with(any_args).and_return(next_app.call)
      get "/", {}, { "HTTP_IDEMPOTENCY_KEY" => "123456789" }
      expect(next_app).to have_received(:call)
    end

    it "returns a Rack response" do
      get "/", {}, { "HTTP_IDEMPOTENCY_KEY" => "123456789" }
      expect(last_response).to be_a(Rack::MockResponse)
    end
  end

  context "with Idempotency-Key header and a non-idempotent method" do
    context "with a previously cached response" do
      before do
        2.times { post "/", {}, { "HTTP_IDEMPOTENCY_KEY" => "123456789" } }
      end

      it "returns the Idempotent-Replayed header" do
        expect(last_response.headers["Idempotent-Replayed"]).to be_truthy
      end
    end

    context "without a previously cached response" do
      it "does not return the Idempotent-Replayed header" do
        post "/", {}, { "HTTP_IDEMPOTENCY_KEY" => "123456789" }
        expect(last_response.headers).not_to have_key("Idempotent-Replayed")
      end

      it "passes the env to the next Middleware" do
        allow(next_app).to receive(:call).with(any_args).and_return(next_app.call)
        post "/", {}, { "HTTP_IDEMPOTENCY_KEY" => "123456789" }
        expect(next_app).to have_received(:call)
      end
    end

    context "when the response code is 400" do
      let(:next_app) { ->(_env) { [400, { "Content-Type" => "text/plain" }, ["BadRequest"]] } }

      it "doesn't cache the response" do
        allow(store).to receive(:set).with(any_args)
        post "/", {}, { "HTTP_IDEMPOTENCY_KEY" => "123456789" }
        expect(store).not_to have_received(:set).with("123456789", next_app)
      end
    end

    context "when another concurrent request was issued" do
      before do
        allow(app).to(
          receive(:handle_request!).and_raise(Rack::IdempotencyKey::ConflictError)
        )
      end

      it "responds with a 409" do
        post "/", {}, { "HTTP_IDEMPOTENCY_KEY" => "123456789" }
        expect(last_response.status).to eq(409)
      end
    end

    context "when the underlying store fails" do
      before do
        allow(app).to(
          receive(:handle_request!).and_raise(Rack::IdempotencyKey::StoreError)
        )
      end

      it "responds with a 503" do
        post "/", {}, { "HTTP_IDEMPOTENCY_KEY" => "123456789" }
        expect(last_response.status).to eq(503)
      end
    end
  end
end
