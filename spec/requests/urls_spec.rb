require 'rails_helper'

RSpec.describe "Urls", type: :request do
  describe "GET /urls/new" do
    it "returns http success for anonymous visitors" do
      get "/urls/new"
      expect(response).to have_http_status(:success)
    end

    it "renders without error when a legacy row has no slug" do
      create(:url).update_column(:shortened_path, nil)
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "does not leak other people's URLs to anonymous visitors" do
      create(:url, original_url: "https://someone-elses-secret.example.com")
      get root_path
      expect(response.body).not_to include("someone-elses-secret.example.com")
    end

    it "shows a signed-in user only their own URLs" do
      user = create(:user)
      create(:url, user: user, original_url: "https://mine.example.com")
      create(:url, original_url: "https://theirs.example.com")

      sign_in user
      get root_path

      expect(response.body).to include("mine.example.com")
      expect(response.body).not_to include("theirs.example.com")
    end
  end

  describe "POST /urls" do
    let(:valid_params) { { url: { original_url: "https://example.com" } } }

    context "when nobody is signed in" do
      it "creates a new URL" do
        expect { post "/urls", params: valid_params }.to change(Url, :count).by(1)
      end

      it "leaves it unowned" do
        post "/urls", params: valid_params
        expect(Url.last.user).to be_nil
      end

      it "redirects to the URL show page" do
        post "/urls", params: valid_params
        expect(response).to redirect_to(url_path(Url.last.shortened_path))
      end

      it "surfaces the new link back on the home page for that session" do
        post "/urls", params: valid_params
        get root_path
        expect(response.body).to include(Url.last.shortened_path)
      end
    end

    context "when signed in" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "assigns the URL to that user" do
        post "/urls", params: valid_params
        expect(Url.last.user).to eq(user)
      end

      it "reuses an existing URL rather than creating a duplicate" do
        post "/urls", params: valid_params
        expect { post "/urls", params: valid_params }.not_to change(Url, :count)
      end

      it "redirects to the same short link on reuse" do
        post "/urls", params: valid_params
        original = Url.last.shortened_path
        post "/urls", params: valid_params
        expect(response).to redirect_to(url_path(original))
      end

      it "does not reuse another user's identical URL" do
        create(:url, user: create(:user), original_url: "https://example.com")
        expect { post "/urls", params: valid_params }.to change(Url, :count).by(1)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { url: { original_url: "not-a-url" } } }

      it "does not create a new URL" do
        expect { post "/urls", params: invalid_params }.not_to change(Url, :count)
      end

      it "re-renders the form with 422 instead of raising" do
        post "/urls", params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "shows the validation message" do
        post "/urls", params: invalid_params
        expect(response.body).to include("prevented this URL from being shortened")
      end
    end
  end

  describe "GET /urls/:id" do
    it "returns http success" do
      url = create(:url)
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
      expect { get "/#{url.shortened_path}"; url.reload }.to change(url, :visits_count).by(1)
    end

    it "records the visit details" do
      get "/#{url.shortened_path}", headers: { "HTTP_REFERER" => "https://example.org/page", "HTTP_USER_AGENT" => "Firefox/121.0" }
      visit = url.visits.last
      expect(visit.referer).to eq("https://example.org/page")
      expect(visit.user_agent).to eq("Firefox/121.0")
    end

    context "with non-existent shortened_path" do
      it "redirects to root path" do
        get "/nonexistent"
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /up" do
    it "is not swallowed by the short-link catch-all" do
      get "/up"
      expect(response).to have_http_status(:success)
    end
  end
end
