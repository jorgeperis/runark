require "rails_helper"

RSpec.describe "Races", type: :request do
  describe "GET /races" do
    context "when authenticated" do
      let(:user) { create(:user) }
      before { sign_in(user) }

      it "shows all canonical races" do
        create(:race, name: "Madrid Marathon")
        create(:race, name: "Valencia 10K")
        get races_path
        expect(response.body).to include("Madrid Marathon")
        expect(response.body).to include("Valencia 10K")
      end

      it "does not show alias races" do
        canonical = create(:race, name: "City Run")
        create(:race, name: "Ciudad Run", merged_into: canonical)
        get races_path
        expect(response.body).not_to include("Ciudad Run")
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

    it "shows a race regardless of who created it" do
      race = create(:race)
      create(:run, race: race, user: other_user)
      get race_path(race)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /races/:id/edit" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    before { sign_in(user) }

    it "allows editing when only the current user has runs" do
      race = create(:race)
      create(:run, race: race, user: user)
      get edit_race_path(race)
      expect(response).to have_http_status(:ok)
    end

    it "redirects when another user has a run on this race" do
      race = create(:race)
      create(:run, race: race, user: other_user)
      get edit_race_path(race)
      expect(response).to redirect_to(race_path(race))
    end
  end

  describe "PATCH /races/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    before { sign_in(user) }

    it "redirects when another user has a run on this race" do
      race = create(:race)
      create(:run, race: race, user: other_user)
      patch race_path(race), params: { race: { name: "New Name" } }
      expect(response).to redirect_to(race_path(race))
    end
  end

  describe "DELETE /races/:id" do
    let(:user) { create(:user) }
    before { sign_in(user) }

    it "deletes a race with no runs" do
      race = create(:race)
      delete race_path(race)
      expect(response).to redirect_to(races_path)
    end

    it "redirects when the race has runs attached" do
      race = create(:race)
      create(:run, race: race, user: user)
      delete race_path(race)
      expect(response).to redirect_to(race_path(race))
    end
  end

  describe "POST /races" do
    let(:user) { create(:user) }
    before { sign_in(user) }

    it "creates a global race" do
      post races_path, params: { race: { name: "New Race", location: "Madrid", distance: 10.0 } }
      expect(Race.last.name).to eq("New Race")
    end
  end

  describe "GET /races/search" do
    let(:user) { create(:user) }
    before { sign_in(user) }

    it "returns matching races as JSON" do
      create(:race, name: "Valencia 10K", location: "Valencia", distance: 10.0)
      create(:race, name: "Madrid Marathon", location: "Madrid", distance: 42.195)
      get search_races_path, params: { q: "valencia" }, as: :json
      json = response.parsed_body
      expect(json.map { _1["text"] }).to include(a_string_including("Valencia 10K"))
      expect(json.map { _1["text"] }).not_to include(a_string_including("Madrid Marathon"))
    end

    it "searches by normalized name ignoring accents" do
      create(:race, name: "València 10K", location: "Valencia", distance: 10.0)
      get search_races_path, params: { q: "valencia" }, as: :json
      json = response.parsed_body
      expect(json.map { _1["text"] }).to include(a_string_including("València 10K"))
    end
  end
end
