require "rails_helper"

RSpec.describe Race, type: :model do
  describe "associations" do
    it "belongs to a user" do
      race = create(:race)
      expect(race.user).to be_a(User)
    end

    it "has many runs and destroys them on delete" do
      race = create(:race)
      create(:run, race: race)
      expect { race.destroy }.to change(Run, :count).by(-1)
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      expect(build(:race, name: "")).not_to be_valid
    end

    it "is invalid without a location" do
      expect(build(:race, location: "")).not_to be_valid
    end

    it "is invalid without a distance" do
      expect(build(:race, distance: nil)).not_to be_valid
    end

    it "is invalid with distance <= 0" do
      expect(build(:race, distance: 0)).not_to be_valid
      expect(build(:race, distance: -1)).not_to be_valid
    end

    it "is invalid when name + distance + location is duplicated for the same user" do
      user = create(:user)
      create(:race, user_id: user.id, name: "City Run", distance: 10.0, location: "Madrid")
      duplicate = build(:race, user_id: user.id, name: "City Run", distance: 10.0, location: "Madrid")
      expect(duplicate).not_to be_valid
    end

    it "allows the same name + distance + location for different users" do
      user_a = create(:user)
      user_b = create(:user)
      create(:race, user_id: user_a.id, name: "City Run", distance: 10.0, location: "Madrid")
      other = build(:race, user_id: user_b.id, name: "City Run", distance: 10.0, location: "Madrid")
      expect(other).to be_valid
    end
  end

  describe "#best_run" do
    it "returns the run with the lowest time" do
      race = create(:race)
      slow = create(:run, race: race, time: 4000, date: 2.years.ago)
      fast = create(:run, race: race, time: 3600, date: 1.year.ago)
      expect(race.best_run).to eq(fast)
    end

    it "returns nil when the race has no runs" do
      expect(create(:race).best_run).to be_nil
    end
  end
end
