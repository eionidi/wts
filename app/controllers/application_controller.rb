class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound do |_|
    respond_to do |f|
      f.html { render file: "#{Rails.root}/public/404", layout: false, status: :not_found }
      f.json { render nothing: true, status: 404 }
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { render json: { response: :error, message: exception.message }, status: 401 }
      format.js { render js: "window.location.replace('#{root_path}')" }
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
