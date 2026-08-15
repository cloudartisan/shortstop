require 'rails_helper'

RSpec.describe "Security headers and third-party assets", type: :request do
  before { get root_path }

  describe "Content-Security-Policy" do
    subject(:csp) { response.headers["Content-Security-Policy"] }

    it "is sent at all" do
      expect(csp).to be_present
    end

    it "only allows scripts from this origin" do
      expect(csp).to include("script-src 'self'")
    end

    it "only allows styles from this origin" do
      expect(csp).to include("style-src 'self'")
    end

    it "blocks plugins and framing" do
      expect(csp).to include("object-src 'none'")
      expect(csp).to include("frame-ancestors 'none'")
    end
  end

  describe "third-party assets" do
    it "loads no scripts or styles from a CDN" do
      expect(response.body).not_to include("cdn.jsdelivr.net")
    end

    # importmap-rails emits two inline blocks of its own; both carry the CSP
    # nonce. What must never come back is a hand-written inline <script> in a
    # template, which is how the clipboard and chart code used to ship.
    it "carries a nonce on every inline script" do
      inline = response.body.scan(/<script(?![^>]*\bsrc=)[^>]*>/)

      expect(inline).to be_present
      expect(inline).to all(include("nonce="))
    end

    it "uses no inline event handlers" do
      expect(response.body).not_to match(/\son(click|load|submit|change|error)=/i)
    end
  end
end
