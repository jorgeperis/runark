require "rails_helper"

RSpec.describe Goal, type: :model do
  let(:user) { create(:user) }

  it "requires distance, target_time and uniqueness of distance per user" do
    create(:goal, user: user, distance: 10.0)
    duplicate = build(:goal, user: user, distance: 10.0)

    expect(duplicate).not_to be_valid
    expect(build(:goal, user: user, distance: nil)).not_to be_valid
    expect(build(:goal, user: user, target_time: nil)).not_to be_valid
  end

  describe "progress and achievement" do
    let(:goal) { create(:goal, user: user, distance: 10.0, target_time: 2400) }

    it "is not achieved and has zero progress without a matching run" do
      expect(goal.achieved?).to be false
      expect(goal.progress).to eq(0.0)
    end

    it "tracks progress toward the target from the best run" do
      race = create(:race, distance: 10.0)
      create(:run, user: user, race: race, distance: 10.0, time: 2500)

      expect(goal.achieved?).to be false
      expect(goal.progress).to be_within(0.001).of(2400.0 / 2500)
    end

    it "is achieved when the best run beats the target" do
      race = create(:race, distance: 10.0)
      create(:run, user: user, race: race, distance: 10.0, time: 2300)

      expect(goal.achieved?).to be true
      expect(goal.progress).to eq(1.0)
    end
  end

  it "parses and formats target_time" do
    goal = Goal.new
    goal.target_time_formatted = "0:40:00"
    expect(goal.target_time).to eq(2400)
    expect(goal.target_time_formatted).to eq("0:40:00")
  end
end
