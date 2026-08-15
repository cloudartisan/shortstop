require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  it "redirects anonymous visitors to sign in" do
    get "/dashboard"
    expect(response).to redirect_to(new_user_session_path)
  end

  context "when signed in" do
    let(:user) { create(:user) }

    before { sign_in user }

    it "returns http success" do
      get "/dashboard"
      expect(response).to have_http_status(:success)
    end

    it "lists the user's own URLs" do
      create(:url, user: user, original_url: "https://mine.example.com")
      get "/dashboard"
      expect(response.body).to include("mine.example.com")
    end

    it "does not list another user's URLs" do
      create(:url, user: create(:user), original_url: "https://theirs.example.com")
      get "/dashboard"
      expect(response.body).not_to include("theirs.example.com")
    end

    it "does not list anonymous URLs" do
      create(:url, :anonymous, original_url: "https://nobody.example.com")
      get "/dashboard"
      expect(response.body).not_to include("nobody.example.com")
    end

    it "renders when a legacy row has no slug" do
      create(:url, user: user).update_column(:shortened_path, nil)
      get "/dashboard"
      expect(response).to have_http_status(:success)
    end
  end
end
