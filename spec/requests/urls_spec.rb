require 'rails_helper'

RSpec.describe "Urls", type: :request do
  describe "GET /urls/new" do
    it "returns http success" do
      get "/urls/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /urls" do
    context "with valid parameters" do
      let(:valid_params) { { url: { original_url: "https://example.com" } } }
      
      it "creates a new URL" do
        expect {
          post "/urls", params: valid_params
        }.to change(Url, :count).by(1)
      end
      
      it "redirects to the URL show page" do
        post "/urls", params: valid_params
        expect(response).to redirect_to(url_path(Url.last.shortened_path))
      end
    end
    
    context "with invalid parameters" do
      let(:invalid_params) { { url: { original_url: "not-a-url" } } }
      
      it "does not create a new URL" do
        expect {
          post "/urls", params: invalid_params
        }.not_to change(Url, :count)
      end
      
      it "renders the new template" do
        post "/urls", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /urls/:id" do
    let(:url) { create(:url) }
    
    it "returns http success" do
      get "/urls/#{url.shortened_path}"
      expect(response).to have_http_status(:success)
    end
    
    context "with non-existent URL" do
      it "redirects to root path" do
        get "/urls/nonexistent"
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /:shortened_path" do
    let(:url) { create(:url) }
    
    it "redirects to the original URL" do
      get "/#{url.shortened_path}"
      expect(response).to redirect_to(url.original_url)
    end
    
    it "increments the visit count" do
      expect {
        get "/#{url.shortened_path}"
        url.reload
      }.to change(url, :visits_count).by(1)
    end
    
    context "with non-existent shortened_path" do
      it "redirects to root path" do
        get "/nonexistent"
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
