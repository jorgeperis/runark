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
    end

    context "when not authenticated" do
      it "redirects to login" do
        get stats_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
