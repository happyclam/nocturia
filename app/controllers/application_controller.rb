class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  unless Rails.configuration.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from AbstractController::ActionNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  helper_method :current_user
  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      reset_session
    end
  end

  def render_404(exception = nil)
    if exception
      logger.warn "Rendering 404 with exception: #{exception.message}"
    end
    render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
  end

  def render_500(exception = nil)
    if exception
      logger.fatal "Rendering 500 with exception: #{exception.message}"
      logger.fatal request.env.map { |key, val| "#{key} => #{val}" }
      logger.fatal exception.backtrace.join("\n")
    end

    respond_to do |format|
      format.html { render template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html' }
      format.json { render json: {message: exception.message}, status: 500 }
    end
  end
end
