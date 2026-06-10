class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }
end
