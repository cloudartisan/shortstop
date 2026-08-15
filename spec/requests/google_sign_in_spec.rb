require 'rails_helper'

RSpec.describe "Google sign-in visibility", type: :request do
  it "is hidden when OAuth is not configured" do
    get new_user_session_path
    expect(response.body).not_to include("Sign in with Google")
  end

  it "is offered once both credentials are present" do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("GOOGLE_CLIENT_ID").and_return("id")
    allow(ENV).to receive(:[]).with("GOOGLE_CLIENT_SECRET").and_return("secret")

    get new_user_session_path

    expect(response.body).to include("Sign in with Google")
  end
end
