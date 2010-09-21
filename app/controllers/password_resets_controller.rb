class PasswordResetsController < ApplicationController
  layout "login"
  before_filter :require_no_user  
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]  

  def new  
    render  
  end  

  def create  
    @user = User.find_by_email(params[:email])  
    if @user  
      @user.deliver_password_reset_instructions!  
      flash[:notice] = "Instructions to reset your password have been emailed to you. Please check your email."
      redirect_to login_url  
    else  
      flash[:warning] = "Invalid email address"  
      render :action => :new  
    end  
  end
  
  def edit  
    render  
  end  

  def update  
    @user.password = params[:user][:password]  
    @user.password_confirmation = params[:user][:password_confirmation] 
    if params[:user][:password] != "" 
      if @user.password == @user.password_confirmation
        if @user.save  
          #check evaluator
          @user.activate! if @user.has_role?(:evaluator)
          flash[:notice] = "Password has been updated, please login with your username and new password"  
          UserSession.create(@user, false) # Log user in manually
          @user.deliver_reset_success!
          redirect_to login_path
        else  
          render :action => :edit  
        end
      else
            flash[:warning] = "Password confirmation doesn't match"
            redirect_to "/password_resets/"+@user.perishable_token+"/edit"
      end
    else
      flash[:warning] = "Password cannot be blank"
      redirect_to "/password_resets/"+@user.perishable_token+"/edit"
      #render :action => :edit  
    end
  end  

  private  
  def load_user_using_perishable_token  
    @user = User.find_using_perishable_token(params[:id])  
    unless @user  
      flash[:notice] = "We're sorry, but we could not locate your account. " +  
      "If you are having issues try copying and pasting the URL " +  
      "from your email into your browser or restarting the " +  
      "reset password process."  
      redirect_to login_url
    end
  end
end
