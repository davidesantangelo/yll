class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception, unless: -> { request.format.json? }
  before_action :set_cache_control_headers

  private

  def set_cache_control_headers
    response.headers["Cache-Control"] = "no-store"
  end
end
