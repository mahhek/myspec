class SubscriptionHistoriesController < ApplicationController
  def index
    @subscription_histories = SubscriptionHistory.user_id_eq(current_user.id).descend_by_status.descend_by_due_on.status_eq("open")
    @closed_subscription_histories = SubscriptionHistory.user_id_eq(current_user.id).descend_by_status.descend_by_due_on.status_eq("closed")
  end
  
  def show
    @subscription_history = SubscriptionHistory.find(params[:id])
  end
  
  def new
    @subscription_history = SubscriptionHistory.new
  end
  
  def create
    @subscription_history = SubscriptionHistory.new(params[:subscription_history])
    if @subscription_history.save
      flash[:notice] = "Successfully created subscription history."
      redirect_to @subscription_history
    else
      render :action => 'new'
    end
  end
  
  def edit
    @subscription_history = SubscriptionHistory.find(params[:id])
  end
  
  def update
    @subscription_history = SubscriptionHistory.find(params[:id])
    if @subscription_history.update_attributes(params[:subscription_history])
      flash[:notice] = "Successfully updated subscription history."
      redirect_to @subscription_history
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @subscription_history = SubscriptionHistory.find(params[:id])
    @subscription_history.destroy
    flash[:notice] = "Successfully destroyed subscription history."
    redirect_to subscription_histories_url
  end
end
