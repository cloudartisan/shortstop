require 'rails_helper'

RSpec.describe Url, type: :model do
  describe "validations" do
    it "is valid with a valid original_url" do
      url = build(:url, original_url: "https://example.com")
      expect(url).to be_valid
    end
    
    it "is invalid without an original_url" do
      url = build(:url, original_url: nil)
      expect(url).not_to be_valid
    end
    
    it "is invalid with a malformed URL" do
      url = build(:url, original_url: "not-a-url")
      expect(url).not_to be_valid
    end
    
    it "ensures shortened_path is unique" do
      create(:url, shortened_path: "abc123")
      duplicate = build(:url, shortened_path: "abc123")
      expect(duplicate).not_to be_valid
    end
  end
  
  describe "#set_shortened_path" do
    it "sets a shortened path based on the ID" do
      url = create(:url)
      expect(url.shortened_path).to eq(url.id.to_base62)
    end
  end
  
  describe "#increment_visits!" do
    it "increments the visits_count" do
      url = create(:url)
      expect { url.increment_visits! }.to change { url.visits_count }.by(1)
    end
  end
  
  describe "#short_url" do
    it "returns a complete URL with host" do
      url = create(:url, shortened_path: "abc123")
      expect(url.short_url("http://short.com")).to eq("http://short.com/abc123")
    end
    
    it "returns nil if shortened_path is not present" do
      url = build(:url, shortened_path: nil)
      expect(url.short_url("http://short.com")).to be_nil
    end
    
    it "returns nil if host is not provided" do
      url = create(:url, shortened_path: "abc123")
      expect(url.short_url(nil)).to be_nil
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
end
