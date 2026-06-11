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

  describe ".time_from_components" do
    it "converts h/m/s into total seconds" do
      expect(Run.time_from_components(hours: 1, minutes: 23, seconds: 45)).to eq(5025)
    end

    it "treats nil as zero" do
      expect(Run.time_from_components(hours: nil, minutes: nil, seconds: nil)).to eq(0)
    end

    it "accepts string inputs as received from form params" do
      expect(Run.time_from_components(hours: "1", minutes: "30", seconds: "0")).to eq(5400)
    end
  end

  describe "#time_hours / #time_minutes / #time_seconds" do
    it "correctly decomposes a time into h/m/s components" do
      run = build(:run, time: 5025) # 1h 23m 45s
      expect(run.time_hours).to eq(1)
      expect(run.time_minutes).to eq(23)
      expect(run.time_seconds).to eq(45)
    end
  end
end
