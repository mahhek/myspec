class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  
  layout 'login'
  # access_control do
  #       allow :admin
  #       allow logged_in, :to => :profile
  #   end
  
  
  def new
    @user = User.new
  end
  # def create
  #     @user = User.new(params[:user])
  #     if @user.save
  #       @user.has_role!(:admin)
  #       flash[:notice] = "Account registered!"
  #       redirect_to jobs_path
  #     else
  #       render :action => :new
  #     end
  #   end
  
  def create
      @user = User.new(params[:user])
      # Saving without session maintenance to skip
      # auto-login which can't happen here because
      # the User has not yet been activated
      if params[:term_and_conditions] == "1"
        if @user.save_without_session_maintenance
          @user.has_role!(:owner)
          @user.deliver_activation_instructions!
          flash[:notice] = "Your account has been created. Please check your e-mail for your account activation instructions."
          redirect_to login_url
        else
          render :action => :new
        end
      else
        flash[:warning] = "User need to agree with our term and conditions"
        redirect_to signup_url
      end
    end
  
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user

    if @user.update_attributes(params[:user])
        flash[:notice] = "Password successfully updated"
        redirect_to profile_path
    else
        render :action => :edit
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    role = @user.has_role?(:evaluator)
    if (@user != @current_user)
      @user.destroy
      flash[:notice] = "User has been removed"
    else
      flash[:error] = "You cannot do this action"
    end
    if !role
      redirect_to staff_path
    else
      redirect_to evaluators_path
    end
  end  
end
