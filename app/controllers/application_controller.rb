class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :configure_permitted_parameters, if: :devise_controller?
  after_filter :store_redirect_path

  def after_sign_out_path_for(resource_or_scope)
    home_path(:ref => "logout")
  end

  def store_redirect_path
    SmartRedirect.new(request, session).set_redirect_path
  end

  def after_sign_in_path_for(resource)
    if current_user.confirmed_at.nil?
      flash[:warning] = "#{render_to_string partial: 'layouts/confirm_email'}"
    end

    after_sign_in_redirect_path
  end

  def not_found_error
    raise ActionController::RoutingError.new('Not Found')
  end

  def bad_request
    raise ActionController::RoutingError.new('Bad Request')
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username << :legal_agreement

    devise_parameter_sanitizer.for( :account_update ) do |u|
      u.permit(
        :email,
        :username,
        :current_password,
        :password,
        :password_confirmation,
        :about
      )
    end
  end

  def after_sign_in_redirect_path
    session[:previous_url] || courses_path(:ref => "login")
  end
end
