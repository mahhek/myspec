# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement
  uses_tiny_mce
  rescue_from 'Acl9::AccessDenied', :with => :access_denied
  include Authentication
  helper :all # include all helpers, all the time
  filter_parameter_logging :password, :password_confirmation
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :is_suspended, :except => [:create, :payment]
  #prawn settings
  require "prawn/measurement_extensions"
  require "prawn/security"
  prawnto :prawn => {:page_size => "LETTER", :top_margin => 1.5.in, :left_margin => 1.35.in, :bottom_margin => 1.in, :right_margin => 1.in }

  def is_suspended
    if params[:controller] != "billing_plans"  && (params[:action] != "change_plan")
      if (logged_in?  && current_user.has_role?(:owner) && current_user.is_suspended)
         flash[:notice] = 'Access Denied. Deactivated account.'
        current_user_session.destroy
        redirect_to login_path
      end
    end
  end
  
  def warning
    @warning = false
    if (logged_in? && current_user.has_role?(:owner) && (current_user.first_name == nil || current_user.company == nil || current_user.telephone == nil || current_user.address == nil))
      flash[:warning] = "<a href='/admin'>You must complete your account information</a>"
      @warning = true
    end
    
  end
  
  private
  
  def report_article_number(number)
    if number.to_s.length == 1
      number = "0#{number}"
    end
    return number
  end

  def make_token
    alphanumerics = [('0'..'9'),('A'..'Z'),('a'..'z')].map {|range| range.to_a}.flatten
    (0...30).map { alphanumerics[Kernel.rand(alphanumerics.size)] }.join
  end

  def make_invoice_number
    alphanumerics = [('0'..'9'),('A'..'Z'),('a'..'z')].map {|range| range.to_a}.flatten
    (0...6).map { alphanumerics[Kernel.rand(alphanumerics.size)] }.join
  end

  def as_user
    if current_user.has_role?(:owner)
      id = current_user.id
    else
      id = current_user.parent_id
    end
    return id
  end
  
  def access_denied
    if current_user
      render :template => 'home/access_denied'
    else
      flash[:notice] = 'Access denied. Try to log in first.'
      redirect_to login_path
    end
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
    if @current_user != nil && @current_user.session_key != session[:session_id]
      #flash[:error] = 'Access Denied. Simultaneous logins detected.'
      current_user_session.destroy
      redirect_to login_path if defined?(@current_user)
    end    
    return @current_user
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
end
