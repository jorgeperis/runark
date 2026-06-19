require "rails_helper"

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user) }
  before { sign_in(user) }

  describe "GET /profile/edit" do
    it "returns 200" do
      get edit_profile_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /profile" do
    it "updates sex and date of birth" do
      patch profile_path, params: { user: { gender: "male", birthdate: "1990-05-01" } }

      user.reload
      expect(user.gender).to eq("male")
      expect(user.birthdate).to eq(Date.new(1990, 5, 1))
      expect(user.profile_complete?).to be true
    end

    it "rejects an invalid gender" do
      patch profile_path, params: { user: { gender: "invalid" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "updates favourite distances" do
      patch profile_path, params: { user: { favourite_distances: [ "5.0", "10.0" ] } }

      expect(user.reload.favourite_distance_keys).to eq([ "5.0", "10.0" ])
    end

    it "clears favourite distances back to the default when none are selected" do
      user.update!(favourite_distances: [ "5.0" ])

      patch profile_path, params: { user: { favourite_distances: [ "" ] } }

      expect(user.reload.favourite_distances).to eq([])
      expect(user.favourite_distance_keys).to eq(COMMON_RACE_DISTANCES.keys)
    end
  end
end
