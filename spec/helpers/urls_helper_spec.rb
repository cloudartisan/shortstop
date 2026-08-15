require 'rails_helper'

RSpec.describe UrlsHelper, type: :helper do
  describe "#full_short_url" do
    it "combines the base URL with the path" do
      allow(helper.request).to receive(:base_url).and_return("http://example.com")
      expect(helper.full_short_url("abc123")).to eq("http://example.com/abc123")
    end

    it "does not shadow the short_url route helper" do
      expect(helper.short_path("abc123")).to eq("/abc123")
    end
  end

  describe "#format_number" do
    it "formats numbers with delimiters" do
      expect(helper.format_number(1000)).to eq("1,000")
    end
  end

  describe "#share_of" do
    it "returns the percentage of the total" do
      expect(helper.share_of(1, 4)).to eq("25.0%")
    end

    it "returns zero rather than dividing by zero" do
      expect(helper.share_of(0, 0)).to eq("0.0%")
    end

    it "sums to 100 across a full breakdown" do
      rows = { "a" => 2, "b" => 1, "c" => 1 }
      total = rows.values.sum
      percentages = rows.values.map { helper.share_of(_1, total).to_f }
      expect(percentages.sum).to eq(100.0)
    end
  end

  describe "#qr_code_svg" do
    it "renders an inline SVG rather than calling a third party" do
      svg = helper.qr_code_svg("http://example.com/abc123")
      expect(svg).to include("<svg")
      expect(svg).not_to include("api.qrserver.com")
    end

    it "labels the QR code for assistive technology" do
      expect(helper.qr_code_svg("http://example.com/abc123"))
        .to include('aria-label="QR code for http://example.com/abc123"')
    end

    it "allows a custom size" do
      expect(helper.qr_code_svg("http://example.com", size: 300)).to include('width="300"')
    end
  end
end
