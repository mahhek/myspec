class SettingsController < ApplicationController
  before_filter :login_required
  access_control do
    allow :support
  end

  def subscriber_payment_history
    @search = Invoice.search(params[:search])
    @invoices = @search.user_id_eq(params[:id]).all(:order => "created_at desc").paginate(:per_page => 20, :page => params[:page])

    @credit_card_information = CreditCardInformtaion.find_by_user_id(params[:id])
    @user = User.find(params[:id])
    @billing_plan = BillingPlan.find_by_user_id(params[:id])
  end

   def change_master

    
     user = User.find_by_id(params[:user][:id])
     if params[:user][:role_ids].blank?
        user.has_no_role!(:master)
     else
       user.has_role!(:master)
     end

     redirect_to "/subscriber_team/#{user.id}"
    end
 

  def update_divisions

    @professional = Professional.find(params[:id])
    old_status = @professional.status
    if @professional.update_attributes(params[:professional])   
      new_status = @professional.status
      if old_status != new_status
        if @professional.status == "denied"
          Notifier.deliver_professional_rejected(@professional, params[:reason_to_reject])
        elsif @professional.status == "pending"
          Notifier.deliver_professional_pending(@professional)
        elsif @professional.status == "active"
          Notifier.deliver_professional_accepted(@professional)
        end
      end
      flash[:notice] = "Professional updated successfully"
      redirect_to :action => "professional_detail", :id => params[:id]
    else
      @divisions = Division.all
       @certifications = Certification.all
      render :action => "professional_detail", :id => params[:id]
    end
    
  end

  def suspend_user
    @owners = User.all(:conditions => "parent_id is null")
  end

  def suspend
    user = User.find(params[:id])
    user.is_suspended = true
    user.save
    Notifier.deliver_suspend_user(user)
    redirect_to "/suspend_user"
  end

  def delete_data
    parent_id = params[:id]
    teams = User.find_all_by_parent_id(parent_id)
    unless teams.blank?
      teams.each do |team|
        notes = SectionNote.find_all_by_user_id(team.id)
        unless notes.blank?
          notes.each do |note|
            note.destory
          end
        end
         documents = SectionDocument.find_all_by_user_id(team.id)
        unless documents.blank?
          documents.each do |document|
            document.destory
          end
        end
        documents = SectionAttachment.find_all_by_user_id(team.id)
        unless documents.blank?
          documents.each do |document|
            document.destory
          end
        end
        notes = StandardSectionNote.find_all_by_user_id(team.id)
        unless notes.blank?
          notes.each do |note|
            note.destory
          end
        end
        team.destroy
      end
    end

    user = User.find(parent_id)
          notes = SectionNote.find_all_by_user_id(user.id)
        unless notes.blank?
          notes.each do |note|
            note.destory
          end
        end
         documents = SectionDocument.find_all_by_user_id(user.id)
        unless documents.blank?
          documents.each do |document|
            document.destory
          end
        end
        documents = SectionAttachment.find_all_by_user_id(user.id)
        unless documents.blank?
          documents.each do |document|
            document.destory
          end
        end
        notes = StandardSectionNote.find_all_by_user_id(user.id)
        unless notes.blank?
          notes.each do |note|
            note.destory
          end
        end
    user.destroy

    redirect_to "/cancelled_subscription"
  end
  
  def activate
    user = User.find(params[:id])
    user.is_suspended = false
    user.save
    Notifier.deliver_activate_user(user)
    redirect_to "/cancelled_subscription"
  end
  
  def activate_cancel
    user = User.find(params[:id])
    user.cancel_subscription = false
    user.cancel_date = nil
    user.save
    Notifier.deliver_activate_user(user)
    redirect_to "/suspend_user"
  end

  def cancelled_subscription
    @owners = User.all(:conditions => "parent_id is null and cancel_subscription = true")
  end
  
  def professionals
    @pending_professionals = Professional.all(:conditions => "status = 'received' or status = 'pending' and expiry_date > #{Time.now.to_date}")
    @active_professionals = Professional.all(:conditions => "status = 'active' and expiry_date > '#{Time.now.to_date}'")
    @denied_professionals = Professional.all(:conditions => "status = 'denied' and expiry_date > '#{Time.now.to_date}'")
    @expired_professionals = Professional.all(:conditions => "expiry_date <= '#{Time.now.to_date}'")
  
  end

  def mark_as_approved
    @professional = Professional.find(params[:id])
    @professional.status = "active"
    @professional.save
    redirect_to :action => "professional_detail", :id => params[:id]
  end
  
  def professional_detail
    @professional = Professional.find(params[:id])
    @divisions = Division.all
    @certifications = Certification.all
  end
  
  def subscribers
    @subscribers = User.all(:conditions => "parent_id is null")
  end
  def timezones
    @timezones = User.find_by_sql("select time_zone as timezone, count(*) as count_user from users group by time_zone")
  end
  def subscriber_team
    @subscriber = User.find(params[:id])
    @user = User.find(params[:id])
    @team_members = User.all(:conditions => "parent_id is not null and parent_id = #{params[:id]}")
  end
  
  def update_subscriber
    @subscriber = User.find(params[:id])
    if params[:master] == "1"
        @subscriber.has_role!(:master)   
    else
        @subscriber.has_no_role!(:master)   
    end
    flash[:notice] = "Subscriber information successfully updated"
    redirect_to subscriber_team_path(:id => @subscriber.id)
  end
  def evaluators
    @evaluator = User.new
    @evaluator_requests = EvaluatorRequest.status_does_not_equal("approved")
    @evaluator_requests_received = EvaluatorRequest.status_does_not_equal("received")
  end
  
  def invite_evaluator
    @evaluators = User.all
    @evaluator_requests = EvaluatorRequest.status_does_not_equal("approved")
    @evaluator_requests_received = EvaluatorRequest.status_does_not_equal("received")
    params[:user][:password] = (0...8).map{65.+(rand(25)).chr}.join
    params[:user][:password_confirmation] = params[:user][:password]
    @evaluator = User.new(params[:user])
    @evaluator.username = @evaluator.email.split("@")[0]
    if @evaluator.save
      @evaluator.has_role!(:owner)
      @evaluator.has_role!(:evaluator)
      @evaluator.has_role!(:admin)
      @subscription_history = SubscriptionHistory.create(:user_id => @evaluator.id, :due_on => Time.now.next_month, :description => "Evaluator Subscription", :amount => 0, :status => "closed")
      @plan = BillingPlan.create(:user_id => @evaluator.id, :plan_type_id => 3, :number_of_user => 3)
      flash[:notice] = "An evaluator invitation has been sent."
      @evaluator.deliver_evaluator_invitation!  
      redirect_to evaluators_path
    else
      render :action => 'evaluators'
    end
  end
  
  def division_list
    @divisions = Division.all
  end
  
  def section_list
    @sections = Section.paginate(:per_page => 25, :page => params[:page])
  end
  
  def paragraph_list
    @paragraphs = Paragraph.paginate(:per_page => 25, :page => params[:page])
  end
  
end
