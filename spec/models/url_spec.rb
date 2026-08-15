require 'rails_helper'

RSpec.describe Url, type: :model do
  describe "validations" do
    it "is valid with a valid original_url" do
      expect(build(:url, original_url: "https://example.com")).to be_valid
    end

    it "is invalid without an original_url" do
      expect(build(:url, original_url: nil)).not_to be_valid
    end

    it "is invalid with a malformed URL" do
      expect(build(:url, original_url: "not-a-url")).not_to be_valid
    end

    it "ensures shortened_path is unique" do
      create(:url, shortened_path: "abc123")
      expect(build(:url, shortened_path: "abc123")).not_to be_valid
    end

    it "rejects slugs that would shadow a real route" do
      Url::RESERVED_SLUGS.each do |slug|
        url = build(:url, shortened_path: slug)
        expect(url).not_to be_valid, "expected #{slug.inspect} to be rejected"
        expect(url.errors[:shortened_path]).to include("is reserved")
      end
    end
  end

  describe "slug generation" do
    it "assigns a slug on create without the controller's help" do
      url = Url.create!(original_url: "https://example.com")
      expect(url.shortened_path).to be_present
      expect(url.shortened_path.length).to eq(Url::SLUG_LENGTH)
    end

    it "does not derive the slug from the id, so links cannot be enumerated" do
      url = Url.create!(original_url: "https://example.com")
      expect(url.shortened_path).not_to eq(url.id.to_base62)
    end

    it "generates distinct slugs" do
      slugs = Array.new(25) { Url.create!(original_url: "https://example.com/#{_1}").shortened_path }
      expect(slugs.uniq.length).to eq(25)
    end

    it "keeps an explicitly assigned slug" do
      url = create(:url, shortened_path: "custom")
      expect(url.reload.shortened_path).to eq("custom")
    end

    it "never persists a row without a slug" do
      expect(Url.create!(original_url: "https://example.com").shortened_path).not_to be_nil
    end
  end

  describe ".resolvable" do
    it "excludes legacy rows whose slug was never generated" do
      good = create(:url)
      orphan = create(:url)
      orphan.update_column(:shortened_path, nil)

      expect(Url.resolvable).to include(good)
      expect(Url.resolvable).not_to include(orphan)
    end
  end

  describe "#short_url" do
    it "returns a complete URL with host" do
      url = create(:url, shortened_path: "abc123")
      expect(url.short_url("http://short.com")).to eq("http://short.com/abc123")
    end

    it "returns nil if shortened_path is not present" do
      expect(build(:url, shortened_path: nil).short_url("http://short.com")).to be_nil
    end

    it "returns nil if host is not provided" do
      expect(create(:url, shortened_path: "abc123").short_url(nil)).to be_nil
    end
  end

  describe ".find_by_shortened_path" do
    it "finds a URL by its shortened path" do
      url = create(:url, shortened_path: "xyz789")
      expect(Url.find_by_shortened_path("xyz789")).to eq(url)
    end

    it "returns nil for nonexistent paths" do
      expect(Url.find_by_shortened_path("nonexistent")).to be_nil
    end
  end

  describe "visits_count" do
    it "tracks visits automatically via the counter cache" do
      url = create(:url)
      expect { create(:visit, url: url) }.to change { url.reload.visits_count }.by(1)
    end

    it "decrements when a visit is destroyed" do
      url = create(:url, :with_visits, visit_count: 2)
      expect { url.visits.first.destroy }.to change { url.reload.visits_count }.by(-1)
    end

    it "stays in step with the visits table" do
      url = create(:url, :with_visits, visit_count: 4)
      expect(url.reload.visits_count).to eq(url.visits.count)
    end
  end

  describe "associations" do
    it "destroys its visits" do
      url = create(:url, :with_visits, visit_count: 2)
      expect { url.destroy }.to change(Visit, :count).by(-2)
    end

    it "may belong to no user" do
      expect(build(:url, :anonymous)).to be_valid
    end
  end
end
