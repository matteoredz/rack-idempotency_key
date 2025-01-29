# frozen_string_literal: true

RSpec.shared_examples "describe store get and set methods" do
  let(:key)   { SecureRandom.uuid }
  let(:value) { [204, {}, []] }

  describe "#get" do
    context "with an existing key" do
      before { store.set(key, value) }

      it { expect(store.get(key)).to eq(value) }
    end

    context "with a non-existing key" do
      it { expect(store.get(key)).to be_nil }
    end

    context "with an expired key" do
      let(:twenty_four_hours_from_now) { Time.now + 86_400 }

      before { store.set(key, value) }

      it "returns nil" do
        Timecop.freeze(twenty_four_hours_from_now) do
          expect(store.get(key)).to be_nil
        end
      end
    end
  end

  describe "#set" do
    context "with a new key-value pair" do
      it "sets the new value" do
        expect(store.set(key, value)).to eq(value)
      end
    end

    context "with an already existing key" do
      let(:new_value) { [200, {}, ["OK"]] }

      before { store.set(key, value) }

      it "does not override the existing value" do # rubocop:disable RSpec/MultipleExpectations
        expect { store.set(key, new_value) }.to raise_error(Rack::IdempotencyKey::ConflictError)
        expect(store.get(key)).to eq(value)
      end
    end
  end
end
