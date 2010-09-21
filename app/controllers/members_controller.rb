class MembersController < ApplicationController
  before_filter :login_required
  before_filter :warning , :except => [:edit_account, :update_account] 
  
  access_control do
       allow :owner
       allow :admin, :except => [:edit_account]
       allow :manager, :except => [:new_staff, :create_new_staff, :new_collaborator, :create_new_member, :edit_staff, :update_staff]
       allow :team, :to => [:profile, :update_password, :new_password]
    end

  def archive
    user = User.find(params[:id])
    user.is_archive = true
    user.save
    flash[:notice] = "Team member archived successfully"
    redirect_to staff_path
    
  end
  
  def show_notification
    @notification = Notification.find(params[:id])
    render :update do |page|
      page << 'Modalbox.show(("<div>'+@notification.description+'</div>"), {title: "'+@notification.title+'", height: 250, width:550});'
    end
  end

  def hide_notification
    un = UserNotificationClose.new
    un.user_id = current_user.id
    un.notification_id = params[:id]
    un.save
    redirect_to "/profile"
  end

  def profile
    @collaborators = Collaborator.find_by_sql("select * from collaborators where status = 'invited' and email = '#{current_user.email}'")
    #@collaborators = Collaborator.find_by_email(current_user.email, :conditions => { :status => "invited"})
    unless @collaborators.blank?
      @collaborator = @collaborators.first
    end
    @user = current_user
    @specification_sections = SpecificationSection.specification_job_is_archive_eq(false).specification_job_client_user_id_eq(as_user).paginate(:order => "specification_sections.updated_at DESC", :per_page => 25, :page => params[:page])
    @shared_specification_sections = SpecificationSection.specification_job_is_archive_eq(false).user_id_eq(current_user.id).paginate(:order => "specification_sections.updated_at DESC", :per_page => 25, :page => params[:page])
    @notifications = Notification.find_by_sql("select * from  notifications where status = 'Active' and due_on > CURDATE() and id NOT IN (select notification_id from user_notification_closes where user_id = #{current_user.id}) order by due_on desc")
    unless @notifications.blank?
      @notification = @notifications.first
    end

  end

  def staff_list

    if current_user.parent_id.nil?
      parent_id = current_user.id
      user = current_user

    else
      parent_id = current_user.parent_id
      user = User.find(parent_id)
    end
    @staffs = User.id_or_parent_id_equals(parent_id).is_archive_equals(false)
    
    @plan_type = user.billing_plan.plan_type
  end

  def archived_members
    if current_user.parent_id.nil?
      parent_id = current_user.id
      user = current_user

    else
      parent_id = current_user.parent_id
      user = User.find(parent_id)
    end
    @staffs = User.id_or_parent_id_equals(parent_id).is_archive_equals(true)
    
  end

  def restore
    if current_user.parent_id.nil?
     user = current_user
    else
     user = current_user.parent
    end
    if user.member_stat != "over"
      user = User.find(params[:id])
      user.is_archive = false
      user.save
      flash[:notice] = "Team member restored successfully"
      redirect_to staff_path
    else
      redirect_to new_staff_path
    end
  end

  def edit_staff
    @staff = User.find(params[:id])
  end
  def update_staff
    @staff = User.find(params[:id])
    if @staff.update_attributes(params[:user])
        @staff.has_role!(:team)
        flash[:notice] = "Member account successfully updated"
        redirect_to staff_path
    else
        render :action => :edit_staff
    end
  end

  def new_staff
    @staff = User.new
  end

  def create_new_staff
    params[:user][:password] = (0...8).map{65.+(rand(25)).chr}.join
    params[:user][:password_confirmation] = params[:user][:password]
    @staff = User.new(params[:user])
    if current_user.parent_id.nil?
      parent_id = current_user.id
    else
      parent_id = current_user.parent.id
    end
    @staff.parent_id = parent_id
    @staff.company = current_user.company
    @staff.address = current_user.address
    if @staff.save
      @staff.activate!
      @staff.has_role!(:team)
      flash[:notice] = "Succesfully created a Team Member account."
      @staff.deliver_password_set_instructions!
      redirect_to staff_path
    else
      render :action => 'new_staff'
    end
  end

  def new_collaborator
    @users = User.username_or_email_like_any(params[:q]).id_does_not_equal(current_user.id)
    @collaborator = Collaborator.new
    @search = Job.search(params[:search])
    @jobs = @search.client_user_id_eq(as_user).paginate(:per_page => 20, :page => params[:page])
  end

  def create_new_member
    params[:user][:password] = (0...8).map{65.+(rand(25)).chr}.join
    params[:user][:password_confirmation] = params[:user][:password]
    @member = User.new(params[:user])
     if current_user.parent_id.nil?
      parent_id = current_user.id
    else
      parent_id = current_user.parent.id
    end
    @member.parent_id = parent_id
    if @member.save
      @member.has_role!(:contractor)
      @member.activate!
      @member.deliver_password_set_instructions!
      flash[:notice] = "Succesfully created a Contractor account."
      redirect_to staff_path
    else
      render :action => 'new_staff'
    end
  end

  def edit_account
    @user = User.find(current_user.id)
  end

  def update_account
   @user = User.find(params[:id])
   @user.first_name = params[:user][:first_name]
   @user.company = params[:user][:company]
   @user.address = params[:user][:address]
   @user.city = params[:user][:city]
   @user.state = params[:user][:state]
   @user.zip = params[:user][:zip]
   @user.telephone = params[:user][:telephone]

    if params[:user][:first_name] == "" || params[:user][:company] == "" || params[:user][:address] == "" || params[:user][:city] == "" || params[:user][:state] == "" || params[:user][:zip] == "" || params[:user][:telephone] == ""
      flash[:warning] = "Subscriber information is missing"
      render :action => "edit_account"
    else
       
      if @user.update_attributes(params[:user])
          flash[:notice] = "Subscriber information successfully updated"
          #redirect_to staff_path
          redirect_to admin_path
      else
          render :action => "edit_account"
      end
    end
  end

  def update_password
    @user = current_user
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.save
      flash[:notice] = "Password has been updated"
      #UserSession.create(@user, false) # Log user in manually
      #@user.deliver_reset_success!
      redirect_to profile_path
    else
      render :action => :new_password
    end
  end

  def new_password
    @user = current_user
  end
end