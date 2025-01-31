# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rack::IdempotencyKey::MemoryStore do
  subject(:store) { described_class.new }

  include_examples "describe store get and set methods"
end
