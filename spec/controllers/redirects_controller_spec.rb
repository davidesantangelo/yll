require "rails_helper"

RSpec.describe "Redirects", type: :request do
  let(:link_url) { "https://example.com" }

  context "when link exists and is not expired" do
    context "and does not require a password" do
      let!(:link) { Link.create!(url: link_url, expires_at: 1.day.from_now, code: "DUMMY123") }

      it "redirects to the URL and increments clicks" do
        clicks_before = link.clicks || 0
        get "/#{link.code}"
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(link.url)
        link.reload
        expect(link.clicks).to eq(clicks_before + 1)
      end
    end

    context "and requires a password" do
      let!(:link) { Link.create!(url: link_url, expires_at: 1.day.from_now, code: "PASS1234", password: "secret") }

      it "prompts for authentication if not provided" do
        get "/#{link.code}"
        expect(response).to have_http_status(401)
      end

      it "redirects and increments clicks when correct credentials are provided" do
        clicks_before = link.clicks || 0
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials(link.code, "secret")
        get "/#{link.code}", headers: { "HTTP_AUTHORIZATION" => credentials }
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(link.url)
        link.reload
        expect(link.clicks).to eq(clicks_before + 1)
      end
    end
  end

  context "when link is expired" do
    let!(:link) do
      l = Link.new(url: link_url, expires_at: 1.day.ago, code: "EXPIRED1")
      l.save(validate: false)
      l
    end

    it "renders the 410 gone page" do
      get "/#{link.code}"
      expect(response).to have_http_status(410)
    end
  end

  context "when link is not found" do
    it "renders a JSON error" do
      get "/nonexistent"
      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response["error"]).to eq("Link not found")
    end
  end
end
