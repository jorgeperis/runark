require "rails_helper"

RSpec.describe AgeGrading do
  let(:user) { create(:user, gender: "male", birthdate: Date.new(1986, 1, 1)) }
  let(:race) { create(:race, distance: 10.0) }
  let(:run) { create(:run, user: user, race: race, distance: 10.0, time: 2000, date: Date.new(2021, 6, 1)) }

  it "returns nil when no coefficient data is loaded" do
    allow(described_class).to receive(:data).and_return({ "standards" => {} })
    expect(described_class.for(run, user)).to be_nil
  end

  it "returns nil when the profile is incomplete" do
    allow(described_class).to receive(:data).and_return({ "standards" => { "male" => { "10.0" => { "35" => 1600 } } } })
    incomplete = create(:user)
    expect(described_class.for(run, incomplete)).to be_nil
  end

  it "computes an age-graded percentage from the standard time" do
    # User is 35 on the run date (2021 - 1986); standard 1600s vs actual 2000s.
    allow(described_class).to receive(:data).and_return({ "standards" => { "male" => { "10.0" => { "35" => 1600 } } } })
    expect(described_class.for(run, user)).to eq(80.0)
  end

  context "with the real WMA tables shipped in config/age_grading.yml" do
    before { described_class.reload! }

    it "is available" do
      expect(described_class.available?).to be true
    end

    it "scores a run at the age standard as ~100%" do
      # Age 35 male 10K standard is 1601s in the 2020 tables.
      runner = create(:user, gender: "male", birthdate: Date.new(1986, 1, 1))
      race = create(:race, distance: 10.0)
      run = create(:run, user: runner, race: race, distance: 10.0, time: 1601, date: Date.new(2021, 6, 1))

      expect(described_class.for(run, runner)).to eq(100.0)
    end
  end
end
