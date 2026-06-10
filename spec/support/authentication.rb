module AuthenticationHelpers
  def sign_in(user)
    session_record = create(:session, user: user)
    cookies.signed[:session_id] = session_record.id
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
