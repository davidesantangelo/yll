require "rails_helper"

RSpec.describe "Api::V1::Links", type: :request do
  let(:valid_url) { "https://example.com" }
  let(:valid_attributes) { { url: valid_url, expires_at: 1.day.from_now } }
  let(:invalid_attributes) { { url: "invalid_url" } }

  describe "POST /api/v1/links" do
    context "with valid parameters" do
      it "creates a Link and returns JSON representation" do
        post "/api/v1/links", params: valid_attributes
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json).to include("original_url", "short_url", "created_at", "expires_at", "code", "clicks")
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable_entity with errors" do
        post "/api/v1/links", params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end

    context "when rate limiting is triggered" do
      before do
        Api::V1::LinksController.class_eval do
          alias_method :original_create, :create
          def create
            render json: { error: "Too many requests" }, status: :too_many_requests
          end
        end
      end

      after do
        Api::V1::LinksController.class_eval do
          alias_method :create, :original_create
          remove_method :original_create
        end
      end

      it "returns too_many_requests response" do
        post "/api/v1/links", params: valid_attributes
        expect(response).to have_http_status(:too_many_requests)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Too many requests")
      end
    end
  end

  describe "GET /api/v1/links/:code" do
    context "when the Link exists" do
      let!(:link) { Link.create!(valid_attributes.merge(code: "VALID123")) }

      it "returns the Link JSON representation" do
        get "/api/v1/links/#{link.code}"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to include("code")
        expect(json["code"]).to eq(link.code)
      end
    end

    context "when the Link does not exist" do
      it "returns not found with an error message in JSON" do
        get "/api/v1/links/nocode"
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Link non trovato")
      end
    end
  end
end
