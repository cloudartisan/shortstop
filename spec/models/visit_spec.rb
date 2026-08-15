require 'rails_helper'

RSpec.describe Visit, type: :model do
  let(:url) { create(:url) }

  describe ".record" do
    let(:request) do
      instance_double(
        ActionDispatch::Request,
        remote_ip: "198.51.100.7",
        user_agent: "Mozilla/5.0 Firefox/121.0",
        referer: "https://news.ycombinator.com/item?id=1"
      )
    end

    it "captures the request details" do
      visit = described_class.record(url, request)

      expect(visit).to be_persisted
      expect(visit.ip_address).to eq("198.51.100.7")
      expect(visit.user_agent).to eq("Mozilla/5.0 Firefox/121.0")
      expect(visit.referer).to eq("https://news.ycombinator.com/item?id=1")
      expect(visit.url).to eq(url)
    end

    it "increments the url's counter cache" do
      expect { described_class.record(url, request) }.to change { url.reload.visits_count }.by(1)
    end

    it "accepts a request with no referer or user agent" do
      bare = instance_double(ActionDispatch::Request, remote_ip: "198.51.100.7", user_agent: nil, referer: nil)
      expect(described_class.record(url, bare)).to be_persisted
    end

    it "logs and returns nil rather than raising, so a redirect is never broken" do
      allow(described_class).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(described_class.new))
      allow(Rails.logger).to receive(:error)

      expect(described_class.record(url, request)).to be_nil
      expect(Rails.logger).to have_received(:error).with(/Failed to record visit/)
    end
  end

  describe "validations" do
    it "requires a url" do
      expect(build(:visit, url: nil)).not_to be_valid
    end
  end
end
