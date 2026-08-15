require 'rails_helper'

RSpec.describe "URL statistics", type: :request do
  let(:owner) { create(:user) }
  let(:owned_url) { create(:url, user: owner) }

  describe "authorisation" do
    it "lets the owner see their own statistics" do
      sign_in owner
      get "/urls/#{owned_url.shortened_path}/stats"
      expect(response).to have_http_status(:success)
    end

    it "refuses another signed-in user" do
      sign_in create(:user)
      get "/urls/#{owned_url.shortened_path}/stats"
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to match(/not authorized/i)
    end

    it "refuses anonymous visitors" do
      get "/urls/#{owned_url.shortened_path}/stats"
      expect(response).to redirect_to(root_path)
    end

    it "redirects to root for an unknown slug" do
      sign_in owner
      get "/urls/nope/stats"
      expect(response).to redirect_to(root_path)
    end
  end

  describe "rendering" do
    it "survives a referer with no host" do
      create(:visit, :hostless_referer, url: owned_url)
      sign_in owner

      get "/urls/#{owned_url.shortened_path}/stats"

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Direct")
    end

    it "handles a URL with no visits at all" do
      sign_in owner
      get "/urls/#{owned_url.shortened_path}/stats"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("No visit data available yet")
    end

    it "buckets browsers by user agent" do
      create(:visit, url: owned_url, user_agent: "Mozilla/5.0 Firefox/121.0")
      create(:visit, url: owned_url, user_agent: "Mozilla/5.0 Chrome/120.0.0.0 Safari/537.36")
      sign_in owner

      get "/urls/#{owned_url.shortened_path}/stats"

      expect(response.body).to include("Firefox")
      expect(response.body).to include("Chrome")
    end

    it "reports percentages that sum to 100 across the table" do
      create_list(:visit, 2, url: owned_url, referer: "https://a.example.com/x")
      create_list(:visit, 2, url: owned_url, referer: "https://b.example.com/y")
      sign_in owner

      get "/urls/#{owned_url.shortened_path}/stats"

      expect(response.body).to include("50.0%")
    end
  end
end
