class RedirectsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :link_not_found
  before_action :set_link, only: :show
  before_action :authenticate, only: :show, if: -> { @link.password_digest.present? }
  after_action :increment_clicks, only: :show, if: -> { response.status == 302 }

  def show
    if @link.expired?
      render file: Rails.root.join("public", "410.html"), status: :gone, layout: false
    else
      # brakeman: ignore UnprotectedRedirect
      redirect_to @link.url, allow_other_host: true
    end
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic("Links") do |username, password|
      username == @link.code && @link.authenticate(password)
    end
  end

  def increment_clicks
    @link.increment!(:clicks)
  end

  def set_link
    @link = Link.find_by!(code: params[:code])
  end

  def link_not_found
    render json: { error: "Link not found" }, status: :not_found
  end
end
