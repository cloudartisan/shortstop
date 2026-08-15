require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with an email and password" do
      expect(build(:user)).to be_valid
    end

    it "requires an email" do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it "requires a unique email" do
      create(:user, email: "taken@example.com")
      expect(build(:user, email: "taken@example.com")).not_to be_valid
    end

    it "requires a password of at least 6 characters" do
      expect(build(:user, password: "12345", password_confirmation: "12345")).not_to be_valid
    end
  end

  describe "associations" do
    it "destroys its urls" do
      user = create(:user)
      create(:url, user: user)
      expect { user.destroy }.to change(Url, :count).by(-1)
    end
  end

  describe ".from_omniauth" do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "google-uid-1",
        info: { email: "new@example.com", name: "New Person" }
      )
    end

    it "creates a user on first sign-in" do
      expect { described_class.from_omniauth(auth) }.to change(described_class, :count).by(1)
    end

    it "copies the profile across" do
      user = described_class.from_omniauth(auth)
      expect(user.email).to eq("new@example.com")
      expect(user.name).to eq("New Person")
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("google-uid-1")
    end

    it "assigns a password so the record is valid" do
      expect(described_class.from_omniauth(auth)).to be_persisted
    end

    it "returns the same user on subsequent sign-ins" do
      first = described_class.from_omniauth(auth)
      expect { @second = described_class.from_omniauth(auth) }.not_to change(described_class, :count)
      expect(@second).to eq(first)
    end
  end
end
