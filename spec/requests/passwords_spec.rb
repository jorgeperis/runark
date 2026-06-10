require "rails_helper"

RSpec.describe "Passwords", type: :request do
  let(:user) { create(:user) }

  describe "GET /passwords/new" do
    it "returns 200" do
      get new_password_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /passwords" do
    context "when the email exists" do
      it "enqueues a reset email and redirects to login" do
        expect {
          post passwords_path, params: { email_address: user.email_address }
        }.to have_enqueued_mail(PasswordsMailer, :reset)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when the email does not exist" do
      it "redirects to login without enqueueing an email" do
        expect {
          post passwords_path, params: { email_address: "nobody@example.com" }
        }.not_to have_enqueued_mail
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET /passwords/:token/edit" do
    context "with a valid token" do
      it "returns 200" do
        get edit_password_path(user.password_reset_token)
        expect(response).to have_http_status(:ok)
      end
    end

    context "with an invalid token" do
      it "redirects to new password path" do
        get edit_password_path("invalid-token")
        expect(response).to redirect_to(new_password_path)
      end
    end
  end

  describe "PATCH /passwords/:token" do
    let(:token) { user.password_reset_token }

    context "with matching passwords" do
      it "updates the password and redirects to login" do
        patch password_path(token), params: { password: "newpassword", password_confirmation: "newpassword" }
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "with mismatched passwords" do
      it "redirects back to the edit form" do
        patch password_path(token), params: { password: "newpassword", password_confirmation: "different" }
        expect(response).to redirect_to(edit_password_path(token))
      end
    end
  end
end
