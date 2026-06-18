require "rails_helper"

RSpec.describe Run, type: :model do
  describe "associations" do
    it "belongs to a race" do
      run = create(:run)
      expect(run.race).to be_a(Race)
    end

    it "belongs to a user" do
      run = create(:run)
      expect(run.user).to be_a(User)
    end
  end

  describe "validations" do
    it "is invalid without a date" do
      expect(build(:run, date: nil)).not_to be_valid
    end

    it "is invalid without a time" do
      expect(build(:run, time: nil)).not_to be_valid
    end

    it "is invalid with time <= 0" do
      expect(build(:run, time: 0)).not_to be_valid
      expect(build(:run, time: -1)).not_to be_valid
    end

    it "is invalid with distance <= 0" do
      expect(build(:run, distance: 0)).not_to be_valid
    end

    it "is invalid when the race belongs to a different user" do
      user_a = create(:user)
      user_b = create(:user)
      race = create(:race, user: user_a)
      run = build(:run, race: race, user: user_b)
      expect(run).not_to be_valid
    end

    it "is valid when the race and run belong to the same user" do
      user = create(:user)
      race = create(:race, user: user)
      expect(build(:run, race: race, user: user)).to be_valid
    end

    it "is invalid with an unrecognised homologated value" do
      run = create(:run)
      run.homologated = nil
      expect(run).not_to be_valid
    end
  end

  describe "callbacks" do
    describe "#set_defaults_from_race" do
      let(:race) { create(:race, distance: 21.097, homologated: true) }

      it "inherits distance from the race when not provided" do
        run = create(:run, race: race, distance: nil)
        expect(run.distance).to eq(21.097)
      end

      it "inherits homologated from the race when not provided" do
        run = create(:run, race: race, homologated: nil)
        expect(run.homologated).to eq(true)
      end

      it "does not overwrite an explicitly provided distance" do
        run = create(:run, race: race, distance: 5.0)
        expect(run.distance).to eq(5.0)
      end

      it "does not run on update" do
        run = create(:run, race: race)
        run.update!(distance: 5.0)
        expect(run.reload.distance).to eq(5.0)
      end
    end
  end

  describe "scopes" do
    describe ".ordered" do
      it "returns runs newest date first" do
        race = create(:race)
        old = create(:run, race: race, date: 1.year.ago)
        recent = create(:run, race: race, date: 1.week.ago)
        expect(Run.ordered).to eq([ recent, old ])
      end
    end

    describe ".search_name" do
      it "matches runs whose race name contains the query" do
        madrid = create(:run, race: create(:race, name: "Madrid Marathon"))
        valencia = create(:run, race: create(:race, name: "Valencia 10K"))
        expect(Run.search_name("madrid")).to eq([ madrid ])
        expect(Run.search_name("madrid")).not_to include(valencia)
      end

      it "escapes LIKE wildcards in the query" do
        plain = create(:run, race: create(:race, name: "City Run"))
        expect(Run.search_name("%")).not_to include(plain)
      end

      it "returns all runs when the query is blank" do
        run = create(:run)
        expect(Run.search_name(nil)).to eq([ run ])
        expect(Run.search_name("")).to eq([ run ])
      end
    end

    describe ".for_year" do
      it "filters runs by the year of their date" do
        in_2024 = create(:run, date: Date.new(2024, 5, 1))
        in_2025 = create(:run, date: Date.new(2025, 5, 1))
        expect(Run.for_year("2024")).to eq([ in_2024 ])
        expect(Run.for_year("2024")).not_to include(in_2025)
      end

      it "returns all runs when the year is blank" do
        run = create(:run)
        expect(Run.for_year(nil)).to eq([ run ])
      end
    end

    describe ".for_distance" do
      it "filters runs by exact distance" do
        ten = create(:run, distance: 10.0)
        half = create(:run, distance: 21.097)
        expect(Run.for_distance(10.0)).to eq([ ten ])
        expect(Run.for_distance(10.0)).not_to include(half)
      end

      it "returns all runs when the distance is blank" do
        run = create(:run)
        expect(Run.for_distance(nil)).to eq([ run ])
      end
    end

    describe ".for_race" do
      it "filters runs by race id" do
        race = create(:race)
        mine = create(:run, race: race)
        other = create(:run, race: create(:race, user: race.user))
        expect(Run.for_race(race.id)).to eq([ mine ])
        expect(Run.for_race(race.id)).not_to include(other)
      end

      it "returns all runs when the race is blank" do
        run = create(:run)
        expect(Run.for_race(nil)).to eq([ run ])
      end
    end

    describe ".sorted_by" do
      it "sorts by distance ascending" do
        race = create(:race)
        long = create(:run, race: race, distance: 42.195)
        short = create(:run, race: race, distance: 5.0)
        expect(Run.sorted_by("distance", "asc")).to eq([ short, long ])
      end

      it "sorts by pace using the derived expression" do
        race = create(:race)
        fast = create(:run, race: race, distance: 10.0, time: 3000) # 300 s/km
        slow = create(:run, race: race, distance: 10.0, time: 4000) # 400 s/km
        expect(Run.sorted_by("pace", "asc")).to eq([ fast, slow ])
      end

      it "falls back to date for an unrecognised column" do
        race = create(:race)
        old = create(:run, race: race, date: 1.year.ago)
        recent = create(:run, race: race, date: 1.week.ago)
        expect(Run.sorted_by("time; DROP TABLE runs", "desc")).to eq([ recent, old ])
      end
    end
  end

  describe "#full_name" do
    it "combines race name and year" do
      race = create(:race, name: "Madrid Marathon")
      run = create(:run, race: race, date: Date.new(2024, 4, 21))
      expect(run.full_name).to eq("Madrid Marathon 2024")
    end
  end

  describe "#pace" do
    it "returns seconds per km rounded to the nearest integer" do
      run = build(:run, time: 3600, distance: 10.0)
      expect(run.pace).to eq(360)
    end

    it "rounds correctly when the result is not exact" do
      run = build(:run, time: 3661, distance: 10.0)
      expect(run.pace).to eq(366)
    end
  end

  describe ".seconds_from_formatted" do
    it "parses a full h:mm:ss string into total seconds" do
      expect(Run.seconds_from_formatted("1:23:45")).to eq(5025)
    end

    it "fills right-to-left so two groups mean minutes and seconds" do
      expect(Run.seconds_from_formatted("45:30")).to eq(2730)
    end

    it "fills right-to-left so a single group means seconds" do
      expect(Run.seconds_from_formatted("30")).to eq(30)
    end

    it "returns nil for blank input" do
      expect(Run.seconds_from_formatted("")).to be_nil
      expect(Run.seconds_from_formatted(nil)).to be_nil
    end
  end

  describe "#time_formatted" do
    it "formats the stored seconds as h:mm:ss with zero-padding" do
      expect(build(:run, time: 5025).time_formatted).to eq("1:23:45")
    end

    it "is nil when time is blank" do
      expect(build(:run, time: nil).time_formatted).to be_nil
    end

    it "round-trips through the writer" do
      run = build(:run)
      run.time_formatted = "1:23:45"
      expect(run.time).to eq(5025)
      expect(run.time_formatted).to eq("1:23:45")
    end
  end
end
