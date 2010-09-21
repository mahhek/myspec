class UserSessionsController < ApplicationController
  layout "login"
  #ssl_required :new, :create 
  #ssl_allowed :destroy
  def new
    @user_session = UserSession.new
  end
  
  def create
    
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      user = User.find_by_username(params[:user_session][:username])
     unless user.is_archive
      unless user.parent_id.blank?
        user = user.parent
        if user.cancel_subscription
          @user_session.destroy
          flash[:warning] = "Your subscription has been cancelled!"
          redirect_to ""
        else
          if user.is_suspended
            @user_session.destroy
            flash[:warning] = "Your account has been suspended. Please contact administrator."
            redirect_to ""
          else
            if user.is_unpaid?
              flash[:warning] = "Please contact administrator."
              redirect_to ""
            else
               @user_session.record.session_key = session[:session_id]
               @user_session.record.save!
               if (current_user.has_role?(:owner) && (current_user.first_name == nil || current_user.company == nil || current_user.telephone == nil || current_user.address == nil))
                flash[:warning] = "You must complete your account information"
                redirect_to admin_path
               else
                #flash[:notice] = "Succesfully logged in"
                redirect_to profile_path
               end
            end
           
          end
        end
      else
        @user_session.record.session_key = session[:session_id]
        @user_session.record.save!
        if user.cancel_subscription
          @user_session.destroy
          flash[:warning] = "You have choosen to cancel your subscription. Please contact support or your data will be deleted on #{user.cancel_date.strftime("%m-%d-%Y")}."
          redirect_to ""
        else
          if user.is_suspended
            flash[:warning] = "You account is deactiavated."
            redirect_to "/change_plan"
          else
            if user.is_unpaid?
              flash[:warning] = "Please enter credit card information."
              redirect_to "/change_plan"
            else
              if (current_user.has_role?(:owner) && (current_user.first_name == nil || current_user.company == nil || current_user.telephone == nil || current_user.address == nil))
                flash[:warning] = "You must complete your account information"
                redirect_to admin_path
              else
                #flash[:notice] = "Succesfully logged in"
                redirect_to profile_path
              end
            end 
          end
        end
      end
    else
      flash[:error] = "wrong email or password or not activated yet"
      redirect_to login_path
      #render :action => 'new'
    end
    else
      flash[:error] = "wrong email or password or not activated yet"
      redirect_to login_path
      #render :action => 'new'
    end
    
  end
  
  def destroy
    @user_session = UserSession.find
    if @user_session != nil 
      flash[:notice] = "Succesfully logout"
      @user_session.destroy
    end
    redirect_to root_url
  end
end
