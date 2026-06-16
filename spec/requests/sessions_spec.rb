require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /session/new" do
    it "returns 200" do
      get new_session_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /session" do
    context "with valid credentials" do
      it "redirects after login" do
        post session_path, params: { email_address: user.email_address, password: "password" }
        expect(response).to redirect_to(stats_path)
      end

      it "creates a session record" do
        expect {
          post session_path, params: { email_address: user.email_address, password: "password" }
        }.to change(Session, :count).by(1)
      end
    end

    context "with invalid credentials" do
      it "redirects back to login" do
        post session_path, params: { email_address: user.email_address, password: "wrong" }
        expect(response).to redirect_to(new_session_path)
      end

      it "does not create a session record" do
        expect {
          post session_path, params: { email_address: user.email_address, password: "wrong" }
        }.not_to change(Session, :count)
      end
    end
  end

  describe "DELETE /session" do
    before { sign_in(user) }

    it "terminates the session and redirects to login" do
      delete session_path
      expect(response).to redirect_to(new_session_path)
    end

    it "destroys the session record" do
      expect { delete session_path }.to change(Session, :count).by(-1)
    end
  end
end
