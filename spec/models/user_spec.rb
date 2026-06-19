require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it "has many sessions and destroys them on delete" do
      user = create(:user)
      create(:session, user: user)
      expect { user.destroy }.to change(Session, :count).by(-1)
    end

    it "has many runs and destroys them on delete" do
      user = create(:user)
      race = create(:race)
      create(:run, race: race, user: user)
      expect { user.destroy }.to change(Run, :count).by(-1)
    end
  end

  describe "validations" do
    it "is invalid without an email_address" do
      expect(build(:user, email_address: "")).not_to be_valid
    end

    it "is invalid with a malformed email_address" do
      expect(build(:user, email_address: "notanemail")).not_to be_valid
      expect(build(:user, email_address: "@nodomain.com")).not_to be_valid
    end

    it "is valid with a properly formed email_address" do
      expect(build(:user, email_address: "jorge@example.com")).to be_valid
    end

    it "is invalid when email_address is already taken" do
      create(:user, email_address: "taken@example.com")
      duplicate = build(:user, email_address: "taken@example.com")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email_address]).to be_present
    end

    it "treats email_address as case-insensitively unique" do
      create(:user, email_address: "jorge@example.com")
      duplicate = build(:user, email_address: "JORGE@EXAMPLE.COM")
      expect(duplicate).not_to be_valid
    end
  end

  describe "normalization" do
    it "strips and downcases email_address on save" do
      user = create(:user, email_address: "  JORGE@EXAMPLE.COM  ")
      expect(user.email_address).to eq("jorge@example.com")
    end
  end

  describe "favourite distances" do
    it "defaults to all common distances when none are set" do
      expect(build(:user).favourite_distance_keys).to eq(COMMON_RACE_DISTANCES.keys)
    end

    it "returns the saved distances in canonical order" do
      user = build(:user, favourite_distances: [ "42.195", "5.0" ])
      expect(user.favourite_distance_keys).to eq([ "5.0", "42.195" ])
    end

    it "exposes the matching common distance data" do
      user = build(:user, favourite_distances: [ "5.0" ])
      expect(user.favourite_race_distances).to eq("5.0" => COMMON_RACE_DISTANCES["5.0"])
    end

    it "strips blank values before saving" do
      user = create(:user, favourite_distances: [ "", "10.0" ])
      expect(user.favourite_distances).to eq([ "10.0" ])
    end

    it "falls back to the default when all distances are removed" do
      user = create(:user, favourite_distances: [ "" ])
      expect(user.favourite_distance_keys).to eq(COMMON_RACE_DISTANCES.keys)
    end

    it "is invalid with an unknown distance" do
      user = build(:user, favourite_distances: [ "999.0" ])
      expect(user).not_to be_valid
      expect(user.errors[:favourite_distances]).to be_present
    end
  end
end
