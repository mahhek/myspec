class ActivationsController < ApplicationController
  before_filter :require_no_user

      def create
        @user = User.find_using_perishable_token(params[:activation_code], 1.week) || (raise Exception)
        raise Exception if @user.active?

        if @user.activate!
          @user.has_role!(:owner)
          @user.has_role!(:admin)
          @user.has_role!(:manager)
          @user.has_role!(:team)
          @subscription_history = SubscriptionHistory.create(:user_id => @user.id, :due_on => Time.now, :description => "New Free 14 days trial Subscription", :amount => 0, :status => "closed")
          @plan = BillingPlan.create(:user_id => @user.id, :plan_type_id => 1, :number_of_user => 1, :number_of_space => 5, :number_of_professional => 0)
          @admin_format = AdminFormat.create(:user_id => @user.id, 
                                            :top_left_1 => "job no", 
                                            :top_left_2 => "date", 
                                            :top_left_3 => "", 
                                            :top_right_1 => "job name", 
                                            :top_right_2 => "job location",
                                            :top_right_3 => "",  
                                            :bottom_left_1 => "section author", 
                                            :bottom_left_2 => "", 
                                            :bottom_left_3 => "", 
                                            :bottom_right_1 => "section name", 
                                            :bottom_right_2 => "section no", 
                                            :bottom_right_3 => "page no")
          flash[:notice] = "Your account has been activated!"
          UserSession.create(@user, false) # Log user in manually
          @user.deliver_welcome!
          redirect_to login_path
        else
          render :action => :new
        end
      end
      
      

end
