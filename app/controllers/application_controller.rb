class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound do |_|
    respond_to do |f|
      f.html { render file: "#{Rails.root}/public/404", layout: false, status: :not_found }
      f.json { render nothing: true, status: 404 }
    end
  end
end
