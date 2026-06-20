require "rails_helper"

RSpec.describe "Stats", type: :request do
  describe "GET /stats" do
    context "when authenticated" do
      let(:user) { create(:user) }
      before { sign_in(user) }

      it "returns 200" do
        get stats_path
        expect(response).to have_http_status(:ok)
      end

      it "shows lifetime totals and progression across years" do
        race = create(:race, distance: 10.0)
        create(:run, user: user, race: race, distance: 10.0, time: 2700, date: Date.new(2024, 5, 1))
        latest = create(:run, user: user, race: race, distance: 10.0, time: 2500, date: Date.new(2026, 5, 1))

        get stats_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Races")
        expect(response.body).to include("Progression")
        expect(response.body).to include(run_path(latest))
        expect(response.body).to include(race.name)
      end

      it "renders the new sections" do
        get stats_path

        expect(response.body).to include("This Season")
        expect(response.body).to include("Activity Calendar")
        expect(response.body).to include("Performance Score")
      end

      it "prompts to complete the profile for scoring when it is missing" do
        get stats_path
        expect(response.body).to include(edit_profile_path)
      end

      it "shows an age-graded percentage once the profile is complete" do
        AgeGrading.reload!
        user.update!(gender: "male", birthdate: Date.new(1986, 1, 1))
        race = create(:race, distance: 10.0)
        create(:run, user: user, race: race, distance: 10.0, time: 1601, date: Date.new(2021, 6, 1))

        get stats_path

        expect(response.body).to include("100.0%")
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get stats_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
