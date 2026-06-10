require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it "has many sessions and destroys them on delete" do
      user = create(:user)
      create(:session, user: user)
      expect { user.destroy }.to change(Session, :count).by(-1)
    end

    it "has many races and destroys them on delete" do
      user = create(:user)
      create(:race, user_id: user.id)
      expect { user.destroy }.to change(Race, :count).by(-1)
    end

    it "has many run_marks and destroys them on delete" do
      user = create(:user)
      race = create(:race, user_id: user.id)
      create(:run_mark, race: race)
      expect { user.destroy }.to change(RunMark, :count).by(-1)
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
end
