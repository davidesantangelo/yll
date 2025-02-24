require "rails_helper"

RSpec.describe Link, type: :model do
  let(:valid_url) { "https://example.com" }
  let(:valid_attributes) { { url: valid_url, expires_at: 1.day.from_now } }
  subject { Link.new(valid_attributes) }

  before do
    # Stub Faraday.head to simulate a reachable URL for any URL string.
    allow(Faraday).to receive(:head).with(anything).and_return(double(success?: true, status: 200))
    # Stub the route helper to return a dummy short URL.
    allow(Rails.application.routes.url_helpers).to receive(:redirect_url).with(any_args) do |code|
      "https://short.url/#{code}"
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      subject.validate
      expect(subject.errors).to be_empty
    end

    it "requires a URL" do
      subject.url = nil
      subject.validate
      expect(subject.errors[:url]).to include("can't be blank")
    end

    it "requires a properly formatted URL" do
      subject.url = "invalid_url"
      subject.validate
      expect(subject.errors[:url]).to include("must be a valid HTTP/HTTPS URL")
    end

    it "requires HTTPS protocol" do
      subject.url = "http://example.com"
      subject.validate
      expect(subject.errors[:url]).to include("must use HTTPS protocol")
    end

    it "requires code of length 8" do
      subject.code = "123"
      subject.validate
      expect(subject.errors[:code]).to include("is the wrong length (should be 8 characters)")
    end

    it "generates a unique code before validation on create" do
      new_link = Link.new(valid_attributes)
      new_link.validate
      expect(new_link.code).to be_present
      expect(new_link.code.length).to eq(8)
    end

    it "validates expires_at is in the future" do
      subject.expires_at = 1.hour.ago
      subject.validate
      expect(subject.errors[:expires_at]).to include("must be in the future")
    end
  end

  describe "#expired?" do
    it "returns false when expires_at is nil" do
      subject.expires_at = nil
      expect(subject.expired?).to be false
    end

    it "returns true if expired" do
      subject.expires_at = 1.hour.ago
      expect(subject.expired?).to be true
    end

    it "returns false if not expired" do
      subject.expires_at = 1.hour.from_now
      expect(subject.expired?).to be false
    end
  end

  describe "#to_param" do
    it "returns the code" do
      subject.validate
      expect(subject.to_param).to eq(subject.code)
    end
  end

  describe "#to_json" do
    it "returns valid JSON with required attributes" do
      subject.validate
      parsed = JSON.parse(subject.to_json)
      expect(parsed).to include("original_url", "short_url", "created_at", "expires_at", "code", "clicks")
    end
  end

  describe "#short_url" do
    it "returns the shortened URL" do
      subject.validate
      expect(subject.short_url).to eq("https://short.url/#{subject.code}")
    end
  end

  describe "validate_url_availability" do
    context "when the URL is reachable" do
      it "does not add an error" do
        subject.validate
        expect(subject.errors[:url]).to be_empty
      end
    end

    context "when the URL is unreachable (Faraday error)" do
      before do
        allow(Faraday).to receive(:head).and_raise(Faraday::Error.new("Connection failed"))
      end

      it "adds an error to the URL" do
        subject.validate
        expect(subject.errors[:url].first).to match(/could not be reached/)
      end
    end

    context "when the URL returns an unsuccessful status" do
      before do
        fake_response = double(success?: false, status: 404)
        allow(Faraday).to receive(:head).with(anything).and_return(fake_response)
      end

      it "adds an error to the URL" do
        subject.validate
        expect(subject.errors[:url]).to include("could not be verified (HTTP 404)")
      end
    end
  end
end
