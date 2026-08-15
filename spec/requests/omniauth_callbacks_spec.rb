require 'rails_helper'

RSpec.describe "Google OAuth callbacks", type: :request do
  describe "a successful callback" do
    before { stub_google_oauth(email: "oauth@example.com", name: "OAuth Person") }

    it "creates the user" do
      expect { get user_google_oauth2_omniauth_callback_path }.to change(User, :count).by(1)
    end

    it "signs them in and redirects" do
      get user_google_oauth2_omniauth_callback_path
      expect(response).to redirect_to(root_path)
    end

    it "does not create a second user on a repeat sign-in" do
      get user_google_oauth2_omniauth_callback_path
      expect { get user_google_oauth2_omniauth_callback_path }.not_to change(User, :count)
    end

    it "copies the profile from Google" do
      get user_google_oauth2_omniauth_callback_path
      user = User.find_by(uid: "google-123")
      expect(user.email).to eq("oauth@example.com")
      expect(user.name).to eq("OAuth Person")
    end
  end

  describe "a failed callback" do
    # In test mode a symbol mock makes the strategy call fail!, which routes
    # through Devise's failure app to OmniauthCallbacksController#failure.
    before { stub_google_oauth_failure(:invalid_credentials) }

    it "redirects to root rather than raising" do
      get user_google_oauth2_omniauth_callback_path
      follow_redirect! while response.redirect? && response.location != root_url
      expect(response.location).to eq(root_url)
    end

    it "creates no user" do
      expect { get user_google_oauth2_omniauth_callback_path }.not_to change(User, :count)
    end
  end
end
