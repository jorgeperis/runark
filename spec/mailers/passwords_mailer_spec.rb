require "rails_helper"

RSpec.describe PasswordsMailer, type: :mailer do
  describe "#reset" do
    let(:user) { create(:user) }
    let(:mail) { described_class.reset(user) }

    it "addresses the user with the expected subject and sender" do
      expect(mail.to).to eq([ user.email_address ])
      expect(mail.subject).to eq("Reset your password")
      expect(mail.from).to eq([ "noreply@arrow.peris.me" ])
    end

    it "includes a reset link to the edit password page" do
      expect(mail.body.encoded).to match(%r{/passwords/.+/edit})
    end
  end
end
