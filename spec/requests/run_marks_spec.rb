require "rails_helper"

RSpec.describe "RunMarks", type: :request do
  describe "GET /run_marks" do
    context "when authenticated" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      before { sign_in(user) }

      it "shows only the current user's run_marks" do
        my_mark = create(:run_mark, race: create(:race, user: user))
        other_mark = create(:run_mark, race: create(:race, user: other_user))
        get run_marks_path
        expect(response.body).to include(my_mark.full_name)
        expect(response.body).not_to include(other_mark.full_name)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get run_marks_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET /run_marks/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    before { sign_in(user) }

    it "returns 404 when accessing another user's run_mark" do
      other_mark = create(:run_mark, race: create(:race, user: other_user))
      get run_mark_path(other_mark)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /run_marks/:id" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    before { sign_in(user) }

    it "returns 404 when deleting another user's run_mark" do
      other_mark = create(:run_mark, race: create(:race, user: other_user))
      delete run_mark_path(other_mark)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /run_marks" do
    let(:user) { create(:user) }
    let(:race) { create(:race, user: user) }
    before { sign_in(user) }

    it "assigns the new run_mark to the current user" do
      post run_marks_path, params: {
        run_mark: {
          race_id: race.id, edition: 1, date: Date.current,
          distance: 10.0, homologated: true,
          time_hours: 1, time_minutes: 0, time_seconds: 0,
          source: "chip"
        }
      }
      expect(RunMark.last.user).to eq(user)
    end
  end
end
