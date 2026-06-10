module AuthenticationHelpers
  # Uses the app's own login endpoint so the signed cookie is set correctly.
  # Factory users are built with password "password".
  def sign_in(user)
    post session_path, params: { email_address: user.email_address, password: "password" }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
