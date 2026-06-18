require "rails_helper"

RSpec.describe Race, type: :model do
  describe "associations" do
    it "has many runs" do
      race = create(:race)
      create(:run, race: race)
      expect(race.runs.count).to eq(1)
    end

    it "restricts deletion when runs exist" do
      race = create(:race)
      create(:run, race: race)
      expect { race.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      expect(Race.exists?(race.id)).to be true
    end

    it "can be deleted when no runs exist" do
      race = create(:race)
      expect { race.destroy }.to change(Race, :count).by(-1)
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

    it "is invalid when normalized name + distance + location is duplicated" do
      create(:race, name: "City Run", distance: 10.0, location: "Madrid")
      duplicate = build(:race, name: "City Run", distance: 10.0, location: "Madrid")
      expect(duplicate).not_to be_valid
    end

    it "treats accented and unaccented names as duplicates" do
      create(:race, name: "Marató de Barcelona", distance: 42.195, location: "Barcelona")
      variant = build(:race, name: "Marato de Barcelona", distance: 42.195, location: "Barcelona")
      expect(variant).not_to be_valid
    end

    it "allows the same name + distance in a different location" do
      create(:race, name: "City Run", distance: 10.0, location: "Madrid")
      other = build(:race, name: "City Run", distance: 10.0, location: "Barcelona")
      expect(other).to be_valid
    end
  end

  describe ".canonical" do
    it "returns races without a merged_into_id" do
      canonical = create(:race)
      aliased = create(:race, name: "Alias Race", merged_into: canonical)
      expect(Race.canonical).to include(canonical)
      expect(Race.canonical).not_to include(aliased)
    end
  end

  describe ".normalize_name" do
    it "transliterates accented characters and lowercases" do
      expect(Race.normalize_name("València")).to eq("valencia")
      expect(Race.normalize_name("Marató")).to eq("marato")
    end

    it "squishes extra whitespace" do
      expect(Race.normalize_name("  City  Run  ")).to eq("city run")
    end
  end

  describe ".search" do
    it "returns canonical races matching the normalized query" do
      create(:race, name: "València 10K", location: "Valencia", distance: 10.0)
      create(:race, name: "Madrid Marathon", location: "Madrid", distance: 42.195)
      results = Race.search("valencia")
      expect(results.map(&:name)).to include("València 10K")
      expect(results.map(&:name)).not_to include("Madrid Marathon")
    end

    it "does not return alias races" do
      canonical = create(:race, name: "City Run", location: "Madrid", distance: 10.0)
      create(:race, name: "Ciudad Run", location: "Madrid", distance: 10.0, merged_into: canonical)
      expect(Race.search("ciudad")).to be_empty
    end
  end

  describe "#canonical_race" do
    it "returns self when not an alias" do
      race = create(:race)
      expect(race.canonical_race).to eq(race)
    end

    it "returns the canonical race when this is an alias" do
      canonical = create(:race)
      aliased = create(:race, name: "Alias Race", merged_into: canonical)
      expect(aliased.canonical_race).to eq(canonical)
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
