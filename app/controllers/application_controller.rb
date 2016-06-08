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
    respond_to do |format|
      format.html do
        flash.now[:error] = exception.message
        redirect_to root_url
      end
      format.json { render json: { response: :error, message: exception.message } }
      format.js { render js: "window.location.replace('#{root_path}')", flash: { error: exception.message } }
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
