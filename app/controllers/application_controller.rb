class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  include Pagy::Method

rescue_from ActiveRecord::RecordNotFound, with: :not_found
rescue_from Pundit::NotAuthorizedError, with: :forbidden

private

# Pundit은 current_user를 기대하지만 Rails 8 auth는 Current.user 패턴 사용
def pundit_user
  Current.user
end

def not_found
  respond_to do |format|
    format.html { render file: Rails.public_path.join("404.html"), status: :not_found, layout: false }
    format.json { render json: { error: "Not found" }, status: :not_found }
  end
end

def forbidden
  respond_to do |format|
    format.html { render file: Rails.public_path.join("403.html"), status: :forbidden, layout: false }
    format.json { render json: { error: "Forbidden" }, status: :forbidden }
  end
end
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
