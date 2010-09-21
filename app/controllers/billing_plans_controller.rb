class BillingPlansController < ApplicationController
  before_filter :login_required
  #ssl_required :new, :create , :edit, :update, :change_plan
  #ssl_allowed :destroy
  access_control do
    allow :owner
  end
  
  include ActiveMerchant::Utils


  
  # def index
  #     @billing_plans = BillingPlan.all
  #   end
  
  def show
    @billing_plan = BillingPlan.find(params[:id])
  end
  
  def new
    @billing_plan = BillingPlan.new
  end

  def update_billing_address
    @user = User.find(current_user.id)
    @user.update_attributes(params[:user])
    @user.save
    redirect_to :payment_info
  end

  def complete_order
    paymentprofile = PaymentProfile.find_by_user_id(current_user.id)
    if current_user.customer_cim_id.blank? || paymentprofile.blank?
      flash[:error] = "No customer profile created yet. Enter your credit card and billing address"
      puts "1"
      redirect_to :action => "summary"
    else
      ActiveMerchant::Billing::Base.mode = :test
      gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
        :login  => "7GU2AFBfen7T",
        :password => "2pLGp539Y3hy8vZv"

      )
      response = gateway.validate_customer_payment_profile(:customer_profile_id => current_user.customer_cim_id, :customer_payment_profile_id => paymentprofile.payment_cim_id, :validation_mode => :test)
      if response.success?
        team_member_subscription = Subscription.find_by_user_id(current_user.id)

        current_billing = 0
        if !current_user.has_role?(:evaluator)
          current_billing =  session["new_team_members"].to_i * 10
        else
          current_billing =  (session["new_team_members"].to_i - 2) * 10
        end

        if session["new_permium_professionals"] == "1"
          current_billing = current_billing + 10
        end

        if session["new_storage"].to_i > 5
          current_storage_billing = (session["new_storage"].to_i - 5) / 5 * 2
          current_billing = current_billing + current_storage_billing
        end

        if team_member_subscription.blank?
          response = gateway.create_customer_profile_transaction({:transaction => {:type => :auth_capture,
                :amount => current_billing,
                :customer_profile_id => current_user.customer_cim_id,
                :customer_payment_profile_id => paymentprofile.payment_cim_id, :recurringBilling => true}})

            if response.success?
              transaction_id = response.params['direct_response']['transaction_id']
              user = User.find(current_user.id)
              user.subscribe_date = Time.now
              user.save

              team_member_subscription = Subscription.new
              team_member_subscription.payment_on = Time.now.to_time.advance(:months => 1).to_date
              team_member_subscription.user_id = current_user.id
              team_member_subscription.amount = current_billing
              team_member_subscription.save
              inv = Invoice.new
              inv.invoice_type = "monthly subscription fees"
              inv.amount = current_billing
              inv.subscription_id = team_member_subscription.id
              inv.user_id = current_user.id
              inv.settled = true
              inv.number = transaction_id
              inv.save
              trans = Transaction.new
              trans.confirmation_id = response.authorization
              trans.invoice_id = inv.id
              trans.save
              @billing_plan = current_user.billing_plan
              @billing_plan.number_of_user = session["new_team_members"]
              @billing_plan.number_of_space = session["new_storage"]
              @billing_plan.number_of_professional = session["new_permium_professionals"]
              if current_user.has_role?(:evaluator)
                @billing_plan.plan_type_id = 3
              else
                @billing_plan.plan_type_id = 2
              end
              @billing_plan.save
              flash[:notice] = "Successfully updated"
              
              puts "2"
              redirect_to :action => "billing_plans", :action => "success"
          else

            flash[:error] = "Error while saving transaction. Please check your credit card"

#            session["new_permium_professionals"] = nil
#            session["new_team_members"] = nil
#            session["new_storage"] = nil
#            session["prorate_team_members"] = nil
#            session["prorate_professionals"] = nil
#            session["prorate_storage"] = nil
            puts "3"
            redirect_to :action => "billing_plans", :action => "failure"
          end
        else
          @billing_plan = current_user.billing_plan
          new_team_members = session["new_team_members"].to_i
          old_charges = team_member_subscription.amount
          current_charges = current_billing

          if current_charges > old_charges
            current = session["prorate_team_members"].to_f + session["prorate_professionals"].to_f + session["prorate_storage"].to_f
            gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
              :login  => "7GU2AFBfen7T",
              :password => "2pLGp539Y3hy8vZv"
            )

            response = gateway.create_customer_profile_transaction({:transaction => {:type => :auth_capture,
                  :amount => current,
                  :customer_profile_id => current_user.customer_cim_id,
                  :customer_payment_profile_id => paymentprofile.payment_cim_id, :recurringBilling => true}})


            if response.success?
              transaction_id = response.params['direct_response']['transaction_id']
              inv = Invoice.new
              inv.invoice_type = "account upgrade fees"
              inv.amount = current
              inv.settled = true
              inv.subscription_id = team_member_subscription.id
              inv.user_id = current_user.id
              inv.number = transaction_id
              inv.save
              trans = Transaction.new
              trans.confirmation_id = response.authorization
              trans.invoice_id = inv.id
              trans.save

              sub = Subscription.find_by_user_id(current_user.id)
              sub.amount = current_billing
              sub.save

              @billing_plan.number_of_user = new_team_members.to_i
              @billing_plan.number_of_space = session["new_storage"].to_i
              @billing_plan.number_of_professional = session["new_permium_professionals"].to_i
              if current_user.has_role?(:evaluator)
                @billing_plan.plan_type_id = 3
              else
                @billing_plan.plan_type_id = 2
              end
              @billing_plan.save
#              session["new_permium_professionals"] = nil
#              session["new_team_members"] = nil
#              session["new_storage"] = nil
#              session["prorate_team_members"] = nil
#              session["prorate_professionals"] = nil
#              session["prorate_storage"] = nil
              puts "4"
              redirect_to :action => "billing_plans", :action => "success"
            else
#              session["new_permium_professionals"] = nil
#              session["new_team_members"] = nil
#              session["new_storage"] = nil
#              session["prorate_team_members"] = nil
#              session["prorate_professionals"] = nil
#              session["prorate_storage"] = nil
              #flash[:error] = "Error while saving transaction. Please check your credit card"
              puts "5"
              redirect_to :action => "billing_plans", :action => "failure"
            end

          else
            sub = Subscription.find_by_user_id(current_user.id)
            sub.amount =  current_billing
            sub.save
            @billing_plan.number_of_user = new_team_members
            @billing_plan.number_of_space = session["new_storage"]
            @billing_plan.number_of_professional = session["new_permium_professionals"]
            if current_user.has_role?(:evaluator)
              @billing_plan.plan_type_id = 3
            else
              @billing_plan.plan_type_id = 2
            end
            @billing_plan.save
#            session["new_permium_professionals"] = nil
#            session["new_team_members"] = nil
#            session["new_storage"] = nil
#            session["prorate_team_members"] = nil
#            session["prorate_professionals"] = nil
#            session["prorate_storage"] = nil
            puts "6"
            redirect_to :action => "billing_plans", :action => "success"
          end
        end
      else
        flash[:error] = "Can not validate your credit card information. Please enter correct information"
        puts "7"
        redirect_to :controller => "billing_plans", :action => "summary"
      end
    end


  end

  def create
    @billing_plan = BillingPlan.new(params[:billing_plan])
    if @billing_plan.save
      flash[:notice] = "Successfully created billing plan."
      redirect_to @billing_plan
    else
      render :action => 'new'
    end
  end
  
  def edit
    @billing_plan = BillingPlan.find(current_user.billing_plan.id)
  end

  def summary
    @credit_card_information = CreditCardInformtaion.find_by_user_id(current_user.id)
    @sub = Subscription.find_by_user_id(current_user.id)
  end
  
  def update
    if params[:premium_professionals].blank?
      params[:premium_professionals] = 0
    end
    @billing_plan = BillingPlan.find(current_user.billing_plan.id)
    @billing_plan.plan_type_id = params[:billing_plan][:plan_type_id]
    new_team_members =  params[:billing_plan][:number_of_user]
    new_permium_professionals = params[:premium_professionals]
    new_storage = params[:billing_plan][:number_of_space]
    if @billing_plan.number_of_professional.blank?
      @billing_plan.number_of_professional = 0
    end
    if @billing_plan.number_of_professional == new_permium_professionals.to_i && @billing_plan.number_of_user == new_team_members.to_i && @billing_plan.number_of_space == new_storage.to_i
      flash[:error] = "You must select something to upgrade"
      redirect_to change_plan_path
    else
      session["new_permium_professionals"] = new_permium_professionals
      session["new_team_members"] = new_team_members
      session["new_storage"] = new_storage
      if current_user.billing_plan.plan_type_id == 1
        redirect_to "/payment_info/?summary=true"
      else
        redirect_to :controller => "billing_plans", :action => "summary"
      end
    end
  end
  
  def destroy
    @billing_plan = BillingPlan.find(params[:id])
    @billing_plan.destroy
    flash[:notice] = "Successfully destroyed billing plan."
    redirect_to billing_plans_url
  end
  
  def change_plan
    #@plans = RSpreedly::SubscriptionPlan.find(:all)
    @billing_plan = BillingPlan.find(current_user.billing_plan.id)
    @subscription_histories = SubscriptionHistory.user_id_eq(current_user.id).descend_by_status.descend_by_due_on.status_eq("open")
    @closed_subscription_histories = SubscriptionHistory.user_id_eq(current_user.id).descend_by_status.descend_by_due_on.status_eq("closed")
    render :action => 'edit'
  end
  
  def cancel
    
  end

  def payment_info
    
    
  end


   def payment
    if params[:card_number] != "" && params[:cardholder_name] != "" && params[:security_code] != ""
      ActiveMerchant::Billing::Base.mode = :test
      credit_card = ActiveMerchant::Billing::CreditCard.new(
        :first_name         => params[:cardholder_name],
        :last_name          => '.',
        :number             => params[:card_number],
        :type =>               params[:creditcard_type],
        :month              => params[:expmo],
        :year               => params[:expyr],
        :verification_value => params[:security_code]
      )
      session[:credit_card] = credit_card
      if credit_card.valid?
        gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
          :login  => "7GU2AFBfen7T",
          :password => "2pLGp539Y3hy8vZv"
          
        )
        session[:gateway] = gateway
        success = false
        if current_user.customer_cim_id == nil
          @user = {:profile => current_user.user_profile}
          puts "aaaa"
          puts @user
          response = gateway.create_customer_profile(@user)
          puts "bbbb"
          session[:response] = response
          if response.authorization
            current_user.update_attributes({:customer_cim_id => response.authorization})
            success = true
          else
            flash[:error] = "Error while creating customer profile"
          end
        else
          success = true
        end

        if success
          success = false
          user = User.find(current_user.id)
          user.update_attributes(params[:user])
          @profile = {:customer_profile_id => user.customer_cim_id,
            :payment_profile => {:bill_to => {:first_name=> current_user.username, :last_name=>'.',
                :address1 => user.billing_address,
                :company => user.company,
                :customer_id => user.id,
                :city => user.billing_city,
                :state => user.billing_state,
                :zip => user.billing_zip,
                :country => user.billing_country,
                :email => user.email,
                :phone => user.telephone
              },
              :payment => {:credit_card => credit_card}
            }
          }
          paymentprofile = PaymentProfile.find_by_user_id(current_user.id)
          if  paymentprofile.blank?
            response = gateway.create_customer_payment_profile(@profile)

            if response.success? and response.params['customer_payment_profile_id']
              success = true
              paymentprofile = PaymentProfile.new
              paymentprofile.payment_cim_id = response.params['customer_payment_profile_id']
              paymentprofile.user_id = current_user.id
              paymentprofile.save
            else
              flash[:error] = "Error occured while saving payment profile"
            end
          else
            @profile = {:customer_profile_id => current_user.customer_cim_id,
              :payment_profile => {:customer_payment_profile_id => paymentprofile.payment_cim_id,
                :bill_to => {:first_name=> user.username, :last_name=>'.',
                  :address1 => user.billing_address,
                  :company => user.company,
                  :customer_id => user.id,
                  :city => user.billing_city,
                  :state => user.billing_state,
                  :zip => user.billing_zip,
                  :country => user.billing_country,
                  :email => user.email,
                  :phone => user.telephone

                },
                :payment => {:credit_card => credit_card}
              }
            }
            response = gateway.update_customer_payment_profile(@profile)

            if response.success?
              success = true
            else
              flash[:error] = "Error occured while saving payment profile"
            end
          end

          if success
            cci = CreditCardInformtaion.find_by_user_id(current_user.id)
            if cci.blank?
              cci = CreditCardInformtaion.new
              cci.user_id = current_user.id
            end
            cci.card_type = params[:creditcard_type]
            cci.cardholder =  params[:cardholder_name]
            cci.credit_card = credit_card.display_number
            expiry_date = DateTime.civil(params[:expyr].to_i, params[:expmo].to_i, 1, 0, 0, 0, 0)

            cci.expiry_date = expiry_date
            cci.save
            flash[:notice] = "Information updated successfully"
          end
        end
      else
        flash[:error] = "Enter valid credit card"
      end
    end


    if params[:summary] == "true" && (flash[:error] == "" || flash[:error] == nil)
      redirect_to "/billing_plans/summary"
    else
      redirect_to :payment_info
    end

    
  end

  def cancel_subscription
    user = User.find(current_user.id)
    user.cancel_subscription = true
    date = Time.now
    user.cancel_date = date.to_time.advance(:months => 1).to_date
    user.save
    @user_session = UserSession.find
    if @user_session != nil
      user.deliver_cancel_subscription!
      flash[:warning] = "Your subscription has been cancelled."
      @user_session.destroy
    end
    redirect_to root_url
  end
  
  def payment_info
    
  end
  

  def payment_history
    @search = Invoice.search(params[:search])
    @invoices = @search.user_id_eq(current_user.id).all(:order => "created_at desc").paginate(:per_page => 20, :page => params[:page])
  end
  
  def member_charge
    @num_user_bill = @num_space_bill = @num_pro_bill = 0
    
    num_of_user = params[:num_of_user]
    num_of_space = params[:num_of_space]
    premium_pro = params[:premium_professionals]
    
    plan = current_user.billing_plan
    cur_num_of_user = plan.number_of_user
    cur_num_of_space = plan.number_of_space
    cur_premium_pro = plan.number_of_professional
    #search next recurring date
    sub = Subscription.user_id_eq(current_user).descend_by_payment_on
    if sub.first != nil
      count_day = (sub.first.payment_on.to_date - Date.today).to_i
    
      #count for number of user
      if num_of_user.to_i > cur_num_of_user
        if count_day > 28
          @num_user_bill = 10 * (num_of_user.to_i - cur_num_of_user)
        # elsif count_day <= 2
        #         @num_user_bill = 0
        else
          @num_user_bill = (count_day * 0.33 * (num_of_user.to_i - cur_num_of_user)).round(2)
        end
      end
    
      if num_of_space.to_i > cur_num_of_space
        if count_day > 28
          @num_space_bill = 2 * ((num_of_space.to_i - cur_num_of_space)/5)
        # elsif count_day <= 2
        #         @num_space_bill = 0
        else
          @num_space_bill =  (count_day * 0.066 * ((num_of_space.to_i - cur_num_of_space)/5)).round(2)
        end
      end
    
      if premium_pro.to_i > cur_premium_pro
        if count_day > 28
          @num_pro_bill = 10
        # elsif count_day <= 2
        #         @num_pro_bill = 0
        else
          @num_pro_bill = (count_day * 0.33).round(2)
        end
      end
    else
      @num_user_bill = (num_of_user.to_i * 10)
      @num_space_bill =  ((num_of_space.to_i - 5)/5) * 2
      @num_pro_bill = (10 * premium_pro.to_i)
    end
    
    session["prorate_professionals"] = @num_pro_bill
    session["prorate_team_members"] = @num_user_bill
    session["prorate_storage"] = @num_space_bill
    @billed = @num_user_bill + @num_space_bill + @num_pro_bill
    
    render :layout => false
  end
  
  def calculate
    
  end
end
