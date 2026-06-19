require "rails_helper"

RSpec.describe EstimatedPaces do
  let(:run) { build(:run, time: 3600, distance: 10.0) }

  describe ".for" do
    it "returns a hash keyed by the common race distance strings by default" do
      result = EstimatedPaces.for(run)
      expect(result.keys).to match_array(COMMON_RACE_DISTANCES.keys)
    end

    it "accepts a custom list of distances" do
      result = EstimatedPaces.for(run, [ "5.0", "10.0" ])
      expect(result.keys).to contain_exactly("5.0", "10.0")
    end
  end

  describe "#calculate" do
    it "applies the Riegel formula: T2 = T1 × (D2/D1)^1.06" do
      expected = 3600 * ((5.0 / 10.0)**1.06)
      result = EstimatedPaces.for(run, [ "5.0" ])
      expect(result["5.0"]).to be_within(0.01).of(expected)
    end

    it "returns the same time when estimating for the reference distance" do
      result = EstimatedPaces.for(run, [ "10.0" ])
      expect(result["10.0"]).to be_within(0.01).of(3600)
    end

    it "produces greater estimated times for longer distances" do
      result = EstimatedPaces.for(run, [ "21.097", "42.195" ])
      expect(result["42.195"]).to be > result["21.097"]
    end

    it "produces lower estimated times for shorter distances" do
      result = EstimatedPaces.for(run, [ "5.0", "10.0" ])
      expect(result["5.0"]).to be < result["10.0"]
    end
  end
end
