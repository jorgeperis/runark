require "rails_helper"

RSpec.describe RunMark, type: :model do
  describe "associations" do
    it "belongs to a race" do
      run_mark = create(:run_mark)
      expect(run_mark.race).to be_a(Race)
    end

    it "belongs to a user" do
      run_mark = create(:run_mark)
      expect(run_mark.user).to be_a(User)
    end
  end

  describe "validations" do
    it "is invalid without a date" do
      expect(build(:run_mark, date: nil)).not_to be_valid
    end

    it "is invalid without a time" do
      expect(build(:run_mark, time: nil)).not_to be_valid
    end

    it "is invalid with time <= 0" do
      expect(build(:run_mark, time: 0)).not_to be_valid
      expect(build(:run_mark, time: -1)).not_to be_valid
    end

    it "is invalid with distance <= 0" do
      expect(build(:run_mark, distance: 0)).not_to be_valid
    end

    it "is invalid when the race belongs to a different user" do
      user_a = create(:user)
      user_b = create(:user)
      race = create(:race, user: user_a)
      run_mark = build(:run_mark, race: race, user: user_b)
      expect(run_mark).not_to be_valid
    end

    it "is valid when the race and run_mark belong to the same user" do
      user = create(:user)
      race = create(:race, user: user)
      expect(build(:run_mark, race: race, user: user)).to be_valid
    end

    it "is invalid with an unrecognised homologated value" do
      run_mark = create(:run_mark)
      run_mark.homologated = nil
      expect(run_mark).not_to be_valid
    end
  end

  describe "callbacks" do
    describe "#set_defaults_from_race" do
      let(:race) { create(:race, distance: 21.097, homologated: true) }

      it "inherits distance from the race when not provided" do
        run_mark = create(:run_mark, race: race, distance: nil)
        expect(run_mark.distance).to eq(21.097)
      end

      it "inherits homologated from the race when not provided" do
        run_mark = create(:run_mark, race: race, homologated: nil)
        expect(run_mark.homologated).to eq(true)
      end

      it "does not overwrite an explicitly provided distance" do
        run_mark = create(:run_mark, race: race, distance: 5.0)
        expect(run_mark.distance).to eq(5.0)
      end

      it "does not run on update" do
        run_mark = create(:run_mark, race: race)
        run_mark.update!(distance: 5.0)
        expect(run_mark.reload.distance).to eq(5.0)
      end
    end
  end

  describe "scopes" do
    describe ".ordered" do
      it "returns run_marks newest date first" do
        race = create(:race)
        old = create(:run_mark, race: race, date: 1.year.ago)
        recent = create(:run_mark, race: race, date: 1.week.ago)
        expect(RunMark.ordered).to eq([ recent, old ])
      end
    end
  end

  describe "#full_name" do
    it "combines race name and year" do
      race = create(:race, name: "Madrid Marathon")
      run_mark = create(:run_mark, race: race, date: Date.new(2024, 4, 21))
      expect(run_mark.full_name).to eq("Madrid Marathon 2024")
    end
  end

  describe "#pace" do
    it "returns seconds per km rounded to the nearest integer" do
      run_mark = build(:run_mark, time: 3600, distance: 10.0)
      expect(run_mark.pace).to eq(360)
    end

    it "rounds correctly when the result is not exact" do
      run_mark = build(:run_mark, time: 3661, distance: 10.0)
      expect(run_mark.pace).to eq(366)
    end
  end

  describe ".time_from_components" do
    it "converts h/m/s into total seconds" do
      expect(RunMark.time_from_components(hours: 1, minutes: 23, seconds: 45)).to eq(5025)
    end

    it "treats nil as zero" do
      expect(RunMark.time_from_components(hours: nil, minutes: nil, seconds: nil)).to eq(0)
    end

    it "accepts string inputs as received from form params" do
      expect(RunMark.time_from_components(hours: "1", minutes: "30", seconds: "0")).to eq(5400)
    end
  end

  describe "#time_hours / #time_minutes / #time_seconds" do
    it "correctly decomposes a time into h/m/s components" do
      run_mark = build(:run_mark, time: 5025) # 1h 23m 45s
      expect(run_mark.time_hours).to eq(1)
      expect(run_mark.time_minutes).to eq(23)
      expect(run_mark.time_seconds).to eq(45)
    end
  end
end
