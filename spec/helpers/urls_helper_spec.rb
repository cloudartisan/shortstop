require 'rails_helper'

RSpec.describe UrlsHelper, type: :helper do
  describe "#short_url" do
    it "combines the base URL with the path" do
      allow(helper.request).to receive(:base_url).and_return("http://example.com")
      expect(helper.short_url("abc123")).to eq("http://example.com/abc123")
    end
  end
  
  describe "#format_number" do
    it "formats numbers with delimiters" do
      expect(helper.format_number(1000)).to eq("1,000")
    end
  end
  
  describe "#qr_code_url" do
    it "generates a QR code URL for a given URL" do
      expected_url = "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=http%3A%2F%2Fexample.com%2Fabc123"
      expect(helper.qr_code_url("http://example.com/abc123")).to eq(expected_url)
    end
    
    it "allows custom size" do
      expected_url = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=http%3A%2F%2Fexample.com"
      expect(helper.qr_code_url("http://example.com", 300)).to eq(expected_url)
    end
  end
end
