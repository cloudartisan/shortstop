require 'rails_helper'

RSpec.describe Base62 do
  describe ".encode" do
    it "encodes zero as the first character of the alphabet" do
      expect(described_class.encode(0)).to eq("0")
    end

    it "encodes small numbers as single characters" do
      expect(described_class.encode(1)).to eq("1")
      expect(described_class.encode(10)).to eq("A")
      expect(described_class.encode(36)).to eq("a")
      expect(described_class.encode(61)).to eq("z")
    end

    it "rolls over to two characters at 62" do
      expect(described_class.encode(62)).to eq("10")
    end

    it "raises on nil rather than NoMethodError" do
      expect { described_class.encode(nil) }.to raise_error(ArgumentError, /must not be nil/)
    end

    it "raises on negative numbers" do
      expect { described_class.encode(-1) }.to raise_error(ArgumentError, /negative/)
    end
  end

  describe ".decode" do
    it "decodes to the original integer" do
      expect(described_class.decode("4")).to eq(4)
      expect(described_class.decode("10")).to eq(62)
    end

    it "treats nil and empty string as zero" do
      expect(described_class.decode(nil)).to eq(0)
      expect(described_class.decode("")).to eq(0)
    end

    it "rejects characters outside the alphabet instead of silently ignoring them" do
      expect { described_class.decode("!!") }.to raise_error(Base62::InvalidCharacter)
      expect { described_class.decode("-1") }.to raise_error(Base62::InvalidCharacter)
    end
  end

  describe "round-tripping" do
    it "returns the original number" do
      [ 0, 1, 61, 62, 3523, 12_345, 999_999_999 ].each do |n|
        expect(described_class.decode(described_class.encode(n))).to eq(n)
      end
    end
  end

  describe ".random" do
    it "returns a slug of the requested length" do
      expect(described_class.random(7).length).to eq(7)
    end

    it "uses only alphabet characters" do
      expect(described_class.random(64)).to match(/\A[0-9A-Za-z]+\z/)
    end

    it "does not repeat itself" do
      expect(Array.new(50) { described_class.random(7) }.uniq.length).to eq(50)
    end
  end

  describe "core extensions" do
    it "adds Integer#to_base62" do
      expect(3523.to_base62).to eq("up")
    end

    it "adds String#from_base62" do
      expect("up".from_base62).to eq(3523)
    end
  end
end
