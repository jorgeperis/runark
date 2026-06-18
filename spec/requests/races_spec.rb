require "rails_helper"

RSpec.describe "Races", type: :request do
  describe "GET /races" do
    context "when authenticated" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      before { sign_in(user) }

      it "shows only the current user's races" do
        my_race = create(:race, user: user, name: "My Race")
        _other_race = create(:race, user: other_user, name: "Other Race")
        get races_path
        expect(response.body).to include("My Race")
        expect(response.body).not_to include("Other Race")
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get races_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET /races/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    before { sign_in(user) }

    it "returns 404 when accessing another user's race" do
      other_race = create(:race, user: other_user)
      get race_path(other_race)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /races/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    before { sign_in(user) }

    it "returns 404 when updating another user's race" do
      other_race = create(:race, user: other_user)
      patch race_path(other_race), params: { race: { name: "Hacked" } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /races/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    before { sign_in(user) }

    it "returns 404 when deleting another user's race" do
      other_race = create(:race, user: other_user)
      delete race_path(other_race)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /races" do
    let(:user) { create(:user) }
    before { sign_in(user) }

    it "assigns the new race to the current user" do
      post races_path, params: { race: { name: "New Race", location: "Madrid", distance: 10.0 } }
      expect(Race.last.user).to eq(user)
    end
  end
end
