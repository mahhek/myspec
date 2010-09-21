class EvaluatorRequestsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :support
       allow :admin, :to => [:new, :create]
  end
  
  def index
    @evaluator_requests = EvaluatorRequest.all
  end
  def new
    @evaluator_request = EvaluatorRequest.new
  end
  
  def create
    @evaluator_request = EvaluatorRequest.new(params[:evaluator_request])
    @evaluator_request.user = current_user
    @evaluator_request.status = "received"
    if @evaluator_request.save
      @evaluator_request.deliver_evaluator_request!
      flash[:notice] = "Your request has been sent."
      redirect_to new_evaluator_request_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @evaluator_request = EvaluatorRequest.find(params[:id])
  end
  
  def show
    @evaluator_request = EvaluatorRequest.find(params[:id])
  end
  
  def update
    @evaluator_request = EvaluatorRequest.find(params[:id])
    if @evaluator_request.update_attributes(params[:evaluator_request])
      if @evaluator_request.status == "approved"
        @evaluator_request.user.has_role!(:evaluator)
        billing_plan = @evaluator_request.user.billing_plan
        billing_plan.plan_type_id = 3
        billing_plan.number_of_user = 2
        billing_plan.save
        #@plan = BillingPlan.create(:user_id => @user.id, :plan_type_id => 1, :number_of_user => 0)
      end
      @evaluator_request.deliver_evaluator_request_update!
      flash[:notice] = "Successfully updated evaluator request."
      redirect_to @evaluator_request
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @evaluator_request = EvaluatorRequest.find(params[:id])
    @evaluator_request.destroy
    flash[:notice] = "Successfully removed evaluator request."
    redirect_to evaluators_url
  end
end
