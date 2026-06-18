require "rails_helper"

RSpec.describe "Races", type: :request do
  describe "GET /races" do
    context "when authenticated" do
      let(:user) { create(:user) }
      before { sign_in(user) }

      it "shows only races where the user has runs" do
        my_race = create(:race, name: "Madrid Marathon")
        create(:run, race: my_race, user: user)
        create(:race, name: "Valencia 10K")
        get races_path
        expect(response.body).to include("Madrid Marathon")
        expect(response.body).not_to include("Valencia 10K")
      end

      it "does not show alias races" do
        canonical = create(:race, name: "City Run")
        alias_race = create(:race, name: "Ciudad Run", merged_into: canonical)
        create(:run, race: canonical, user: user)
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

    it "shows a link to the existing race on duplicate name + distance + location" do
      existing = create(:race, name: "City Run", location: "Madrid", distance: 10.0)
      post races_path, params: { race: { name: "City Run", location: "Madrid", distance: 10.0 } }
      expect(response.body).to include(race_path(existing))
    end

    it "treats accented duplicates as the same race" do
      existing = create(:race, name: "Marató de Barcelona", location: "Barcelona", distance: 42.195)
      post races_path, params: { race: { name: "Marato de Barcelona", location: "Barcelona", distance: 42.195 } }
      expect(response.body).to include(race_path(existing))
    end
  end

  describe "POST /races/:id/merge" do
    let(:admin) { create(:user, admin: true) }
    let(:regular) { create(:user) }

    it "blocks non-admins" do
      sign_in(regular)
      race = create(:race)
      target = create(:race, name: "Target Race")
      post merge_race_path(race), params: { target_id: target.id }
      expect(response).to redirect_to(root_path)
    end

    context "as admin" do
      before { sign_in(admin) }

      it "re-points runs from the source to the target" do
        source = create(:race, name: "Old Name")
        target = create(:race, name: "Canonical Name")
        run = create(:run, race: source, user: admin)
        post merge_race_path(source), params: { target_id: target.id }
        expect(run.reload.race).to eq(target)
      end

      it "marks the source as an alias of the target" do
        source = create(:race, name: "Old Name")
        target = create(:race, name: "Canonical Name")
        post merge_race_path(source), params: { target_id: target.id }
        expect(source.reload.merged_into).to eq(target)
      end

      it "resets the counter cache on the target" do
        source = create(:race, name: "Old Name")
        target = create(:race, name: "Canonical Name")
        create(:run, race: source, user: admin)
        post merge_race_path(source), params: { target_id: target.id }
        expect(target.reload.runs_count).to eq(1)
      end

      it "rejects merging a race into itself" do
        race = create(:race)
        post merge_race_path(race), params: { target_id: race.id }
        expect(response).to redirect_to(race_path(race))
      end

      it "rejects merging races with different distances" do
        source = create(:race, name: "Old 5K", distance: 5.0)
        target = create(:race, name: "Canonical 10K", distance: 10.0)
        post merge_race_path(source), params: { target_id: target.id }
        expect(response).to redirect_to(race_path(source))
        expect(source.reload.merged_into).to be_nil
      end

      it "redirects to the target after a successful merge" do
        source = create(:race, name: "Old Name")
        target = create(:race, name: "Canonical Name")
        post merge_race_path(source), params: { target_id: target.id }
        expect(response).to redirect_to(race_path(target))
      end
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
