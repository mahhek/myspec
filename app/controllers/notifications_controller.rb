class NotificationsController < ApplicationController
  before_filter :login_required
  


  access_control do
    allow :support
  end
  
  def index
    @notifications = Notification.all
    if params[:id].blank?
      @notification = Notification.new
    else
      @notification = Notification.find(params[:id])
    end
  end
  
  def show
    @notification = Notification.find(params[:id])
  end
  
  def new
    @notification = Notification.new
  end
  
  def nl2br(text)
    return text
  end
  
  def create
     
    params[:notification][:description] = params[:notification][:description].gsub(/\r\n/, "") 
    @notification = Notification.new(params[:notification])
    if params[:notification][:status] == "Pending"
      @notification.due_on = nil
    else
      @notification.sent_date = Time.now
    end
    if @notification.save
      flash[:notice] = "Successfully created notification."
      redirect_to notifications_path
    else
      @notifications = Notification.all
      render :action => 'index'
    end
  end
  
  def edit
    @notification = Notification.find(params[:id])
  end
  
  def update
    @notification = Notification.find(params[:id])
    params[:notification][:description] = params[:notification][:description].gsub(/\r\n/, "")
    if @notification.update_attributes(params[:notification])
      if params[:notification][:status] == "Pending"
        @notification.due_on = nil
      else
        @notification.sent_date = Time.now
      end
      @notification.save
      flash[:notice] = "Successfully updated notification."
      redirect_to notifications_path
    else
      render :action => 'index'
    end
  end
  
  def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy
    flash[:notice] = "Successfully destroyed notification."
    redirect_to notifications_url
  end
  
end
