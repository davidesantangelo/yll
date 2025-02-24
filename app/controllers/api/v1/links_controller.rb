module Api
  module V1
    class LinksController < ApplicationController
      rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render_rejection :too_many_requests }
      protect_from_forgery with: :null_session

      # POST /api/v1/links
      def create
        link = Link.new(link_params)
        if link.save
          render json: link.to_json, status: :created
        else
          render json: { errors: link.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/links/:code
      def show
        link = Link.find_by(code: params[:code])
        if link
          render json: link.to_json
        else
          render json: { error: "Link non trovato" }, status: :not_found
        end
      end

      private

      def link_params
        params.permit(:url, :password, :expires_at)
      end
    end
  end
end
