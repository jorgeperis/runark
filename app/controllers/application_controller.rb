class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }

  around_action :switch_locale

  private

  def switch_locale(&action)
    I18n.with_locale(current_locale, &action)
  end

  def current_locale
    locale = session[:locale]
    I18n.available_locales.map(&:to_s).include?(locale) ? locale : I18n.default_locale
  end
end
