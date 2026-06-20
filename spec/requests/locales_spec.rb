require "rails_helper"

RSpec.describe "Locale switching", type: :request do
  it "renders Spanish by default" do
    get new_session_path
    expect(response.body).to include("Iniciar sesión")
  end

  it "switches to English and persists across requests" do
    put locale_path("en"), headers: { "HTTP_REFERER" => new_session_path }
    expect(response).to redirect_to(new_session_path)

    get new_session_path
    expect(response.body).to include("Sign in")
  end

  it "ignores unsupported locales and keeps the default" do
    put locale_path("fr"), headers: { "HTTP_REFERER" => new_session_path }

    get new_session_path
    expect(response.body).to include("Iniciar sesión")
  end
end
