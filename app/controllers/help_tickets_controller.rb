class HelpTicketsController < ApplicationController
  before_filter :login_required, :warning
  access_control do
       allow :owner
       allow :admin
       allow :manager
       allow :support
  end

  def update_notification_div
    render :update do |page|
      page["support_div"].replace_html :partial => "/layouts/support_tab"
    end  
  end

  def update_notification_div_user
    render :update do |page|
      page["top-nav"].replace_html :partial => "/layouts/help_tab"
    end
  end
  
  def professionals
    @divisions = Division.all
    @active_professionals = Professional.all(:conditions => "status = 'active' and expiry_date > '#{Time.now.to_date}'")
    @features_professionals = Professional.all(:conditions => "status = 'active' and expiry_date > '#{Time.now.to_date}' and premium_provider = 1")
  end

  def professional_detail
    @professional = Professional.find(params[:id])
  end
  
  def index
    @help_tickets = HelpTicket.all
  end

  def change_mood
    @help_ticket = HelpTicket.find(params[:id])
    @help_ticket.end_mood = params[:mood]
    @help_ticket.save
    render :update do |page|
      page << "window.location = '/help_tickets/message_user/#{params[:id]}'"
    end
    
  end
  
  def change_status
    @help_ticket = HelpTicket.find(params[:id])
    @help_ticket.status = params[:status]
    @help_ticket.save
    @help_ticket_message = HelpTicketMessage.new
    @help_ticket_message.user_id = current_user.id
    @help_ticket_message.user_type = "2"
    @help_ticket_message.help_ticket_id = params[:id]
    @help_ticket_message.subject = "Help ticket marked as #{params[:status]}"
    @help_ticket_message.message = "Help ticket has been marked as #{params[:status]} by SpecWriter. Please update the mood of this help ticket accordingly."
    @help_ticket_message.save
    redirect_to :action => "message_dev", :id => params[:id]
    
  end
  

   def message_user
    if request.post?
      @help_ticket_message = HelpTicketMessage.new(params[:help_ticket_message])
      @help_ticket_message.user_id = current_user.id
      @help_ticket_message.user_type = "1"
      @help_ticket_message.help_ticket_id = params[:id]
      if @help_ticket_message.save
        redirect_to :action => "message_user", :id => params[:id]
      else
          @help_ticket = HelpTicket.find(params[:id])
          @messages = HelpTicketMessage.find_all_by_help_ticket_id(params[:id])
          render :action => "message_user", :id => params[:id]
      end

    else
      @unread = HelpTicketMessage.all(:conditions => "help_ticket_id = #{params[:id]} and user_type = 2 and is_read = 0")
      unless @unread.blank?
        @unread.each do |un|
          un.is_read = true
          un.save
        end
      end
    @help_ticket = HelpTicket.find(params[:id])
    @messages = HelpTicketMessage.find_all_by_help_ticket_id(params[:id])
    @help_ticket_message = HelpTicketMessage.new

    end

  end
  
  def message_dev
    if request.post?
      @help_ticket_message = HelpTicketMessage.new(params[:help_ticket_message])
      @help_ticket_message.user_id = current_user.id
      @help_ticket_message.user_type = "2"
      @help_ticket_message.help_ticket_id = params[:id]
      if @help_ticket_message.save
        @help_ticket = HelpTicket.find(params[:id])
        @help_ticket.status = "pending"
        @help_ticket.save
        redirect_to :action => "message_dev", :id => params[:id]
      else
          @help_ticket = HelpTicket.find(params[:id])
          @messages = HelpTicketMessage.find_all_by_help_ticket_id(params[:id])
          render :action => "message_dev", :id => params[:id]
      end   
    else
      
      @unread = HelpTicketMessage.all(:conditions => "help_ticket_id = #{params[:id]} and user_type = 1 and is_read = 0")
      unless @unread.blank?
        @unread.each do |un|
          un.is_read = true
          un.save
        end
      end
    @help_ticket = HelpTicket.find(params[:id])
    @help_ticket.is_read = true
    @help_ticket.save

    @messages = HelpTicketMessage.find_all_by_help_ticket_id(params[:id])
    @help_ticket_message = HelpTicketMessage.new
    end
    
  end

  def new
    @help_tickets = HelpTicket.user_id_eq(current_user.id).descend_by_created_at
    @help_ticket = HelpTicket.new
  end
  
  def create
    @help_ticket = HelpTicket.new(params[:help_ticket])
    @help_ticket.user_id = current_user.id
    @help_ticket.status = "received"
    if @help_ticket.save
      @help_ticket.deliver_help_ticket!
      @help_ticket.deliver_help_success!
      flash[:notice] = "Successfully created help ticket."
      redirect_to "/help_tickets/new"
    else
      @help_tickets = HelpTicket.user_id_eq(current_user.id).descend_by_created_at

      render :action => 'new'
    end
  end
  
  def destroy
    @help_ticket = HelpTicket.find(params[:id])
    @help_ticket.destroy
    flash[:notice] = "Successfully remove help ticket."
    redirect_to "/help_tickets/new"
  end
end
