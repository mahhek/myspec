class CollaboratorsController < ApplicationController
  def index
    #@collaborators = Collaborator.all
    @collaborators = Collaborator.user_id_eq(as_user)
    @users = User.username_or_email_like_any(params[:q]).id_does_not_equal(current_user.id)
    @collaborator = Collaborator.new
    @search = Job.search(params[:search])
    @jobs = @search.client_user_id_eq(as_user).paginate(:per_page => 20, :page => params[:page])
  end
  
  def show
    @collaborator = Collaborator.find(params[:id])
  end
  
  def new
    @users = User.username_or_email_like_any(params[:q]).id_does_not_equal(current_user.id)
    @collaborator = Collaborator.new
    @search = Job.search(params[:search])
    @jobs = @search.client_user_id_eq(as_user).paginate(:per_page => 20, :page => params[:page])
  end
  
  def activation
    @collaborator = Collaborator.find_by_token(params[:token])
  end
  
  def respond
    @collaborator = Collaborator.find(params[:collaborator][:id])
    if params[:accept_button]
      @collaborator.status = "accepted"
      flash[:notice] = "Invitation has been accepted"
    else
      @collaborator.status = "denied"
      flash[:notice] = "Invitation has been rejected"
    end
    @collaborator.save
    redirect_to profile_path
  end
  
  def create
    @user = User.find_by_email(params[:collaborator][:email])
    @collaborator = Collaborator.new(params[:collaborator])
    @collaborators = Collaborator.user_id_eq(as_user)
    if current_user.parent_id.nil?
      user = current_user
    else
      user = current_user.parent
    end
    @collaborator.user = user
    @collaborator.status = "invited"
    if @user != nil
      if @user.has_role?(:admin) || @user.has_role?(:manager) || @user.has_role?(:owner)
          if @collaborator.save 
            # if @collaborator.save
              @collaborator.send_invitation!
              flash[:notice] = "Successfully created collaborator."
              #redirect_to @collaborator
              redirect_to collaborators_path
            # else
            #               @users = User.username_or_email_like_any(params[:q]).id_does_not_equal(current_user.id)
            #               @search = Job.search(params[:search])
            #               @jobs = @search.client_user_id_eq(as_user).paginate(:per_page => 20, :page => params[:page])
            #               render 'members/new_collaborator'
            #             end
          else
            #flash[:error] = "No job selected"
            render :action => "index"
            #redirect_to new_collaborator_path
          end
      else
        flash[:error] = "This user is a team member"
        render :action => "index"
      end
    else
      #replace this later with new user registration
      #if @collaborator.jobs.count > 0
        if @collaborator.save
          Notifier.deliver_new_user_collaborator(@collaborator)
          flash[:notice] = "Invitation to join myspecwriter has been sent"
          redirect_to staff_path
        else
          @users = User.username_or_email_like_any(params[:q]).id_does_not_equal(current_user.id)
          @search = Job.search(params[:search])
          @jobs = @search.client_user_id_eq(as_user).paginate(:per_page => 20, :page => params[:page])
          render :action => 'index'
        end
      # else
      #         flash[:error] = "No job selected"
      #         redirect_to new_collaborator_path
      #       end
    end
  end
  
  def edit
    @collaborator = Collaborator.find(params[:id])
  end
  
  def update
    @collaborator = Collaborator.find(params[:id])
    j = 0
    for job in params[:collaborator][:job_ids]
      if job.to_s != ""
        j += 1
      end
    end
    if j > 0
      if @collaborator.update_attributes(params[:collaborator])
        flash[:notice] = "Successfully updated collaborator."
        redirect_to collaborators_path
      else
        @users = User.username_or_email_like_any(params[:q]).id_does_not_equal(current_user.id)
        @search = Job.search(params[:search])
        @jobs = @search.client_user_id_eq(as_user).paginate(:per_page => 20, :page => params[:page])
        render :action => 'edit'
      end
    else
      @users = User.username_or_email_like_any(params[:q]).id_does_not_equal(current_user.id)
      @search = Job.search(params[:search])
      @jobs = @search.client_user_id_eq(as_user).paginate(:per_page => 20, :page => params[:page])
      flash[:warning] = "No job selected"
      render :action => 'edit'
    end
  end
  
  def destroy
    @collaborator = Collaborator.find(params[:id])
    @collaborator.destroy
    flash[:notice] = "Successfully removed collaborator."
    redirect_to redirect_to collaborators_path
  end
  
  def verify_collaborator
    @collaborator = Collaborator.find_by_token(params[:token])
    @user = User.new
    @user_session = UserSession.new
    @user.username = @collaborator.email.split('@')[0]
    @user.password = (0...8).map{65.+(rand(25)).chr}.join
    @user.password_confirmation = @user.password
    #@user.password_confirmation = @user.password
    @user.email = @collaborator.email
    if @user.save
      @user.activate!
      @user.has_role!(:admin)
      flash[:notice] = "Your account successfully created. Please check your email and follow the instructions."
      @user.deliver_password_reset_instructions!  
      redirect_to login_path
      #redirect_to edit_password_reset_url(@user.perishable_token)  
    else
      flash[:notice] = "Failed"
      redirect_to login_path
    end
  end
end
