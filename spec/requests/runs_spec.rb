require "rails_helper"

RSpec.describe "Runs", type: :request do
  describe "GET /runs" do
    context "when authenticated" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      before { sign_in(user) }

      it "shows only the current user's runs" do
        my_run = create(:run, race: create(:race, user: user))
        other_run = create(:run, race: create(:race, user: other_user))
        get runs_path
        expect(response.body).to include(my_run.full_name)
        expect(response.body).not_to include(other_run.full_name)
      end

      it "filters by search query on the race name" do
        madrid = create(:run, race: create(:race, user: user, name: "Madrid Marathon"))
        valencia = create(:run, race: create(:race, user: user, name: "Valencia 10K"))
        get runs_path, params: { q: "madrid" }
        expect(response.body).to include(madrid.full_name)
        expect(response.body).not_to include(valencia.full_name)
      end

      it "filters by year" do
        in_2024 = create(:run, race: create(:race, user: user), date: Date.new(2024, 5, 1))
        in_2025 = create(:run, race: create(:race, user: user), date: Date.new(2025, 5, 1))
        get runs_path, params: { year: "2024" }
        expect(response.body).to include(in_2024.full_name)
        expect(response.body).not_to include(in_2025.full_name)
      end

      it "filters by distance" do
        ten = create(:run, race: create(:race, user: user), distance: 10.0)
        half = create(:run, race: create(:race, user: user), distance: 21.097)
        get runs_path, params: { distance: 10.0 }
        expect(response.body).to include(ten.full_name)
        expect(response.body).not_to include(half.full_name)
      end

      it "filters by race" do
        race = create(:race, user: user)
        on_race = create(:run, race: race)
        other = create(:run, race: create(:race, user: user))
        get runs_path, params: { race_id: race.id }
        expect(response.body).to include(on_race.full_name)
        expect(response.body).not_to include(other.full_name)
      end

      it "does not error on an unrecognised sort param" do
        create(:run, race: create(:race, user: user))
        get runs_path, params: { sort: "time; DROP TABLE runs" }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get runs_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET /runs/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    before { sign_in(user) }

    it "returns 404 when accessing another user's run" do
      other_run = create(:run, race: create(:race, user: other_user))
      get run_path(other_run)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /runs/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    before { sign_in(user) }

    it "returns 404 when deleting another user's run" do
      other_run = create(:run, race: create(:race, user: other_user))
      delete run_path(other_run)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /runs" do
    let(:user) { create(:user) }
    let(:race) { create(:race, user: user) }
    before { sign_in(user) }

    it "assigns the new run to the current user" do
      post runs_path, params: {
        run: {
          race_id: race.id, date: Date.current,
          distance: 10.0, homologated: true,
          time_formatted: "1:00:00"
        }
      }
      expect(Run.last.user).to eq(user)
    end

    it "parses the formatted time into seconds" do
      post runs_path, params: {
        run: {
          race_id: race.id, date: Date.current,
          distance: 10.0, homologated: true,
          time_formatted: "45:30"
        }
      }
      expect(Run.last.time).to eq(2730)
    end
  end
end
