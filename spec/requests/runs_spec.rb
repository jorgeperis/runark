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
          time_hours: 1, time_minutes: 0, time_seconds: 0
        }
      }
      expect(Run.last.user).to eq(user)
    end
  end
end
