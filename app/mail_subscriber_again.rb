class MailSubscriberAgain < ApplicationController
  # This script deletes all posts that are over 5 minutes old
    
    subretries = SubscriptionRetry.all(:conditions => "CONVERT(retry_on, date) = '#{Time.now.to_date}'" )
    unless subretries.blank?
      subretries.each do |sretry|
        subscription = Subscription.find(sretry.subscription_id)
        user = User.find(subscription.user_id)

        if user.active && !(user.is_suspended) && !(user.cancel_subscription)

          ActiveMerchant::Billing::Base.mode = :test
          gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
            :login  => "7GU2AFBfen7T",
            :password => "2pLGp539Y3hy8vZv"
          )
          paymentprofile = PaymentProfile.find_by_user_id(user.id)
          response = gateway.validate_customer_payment_profile(:customer_profile_id => user.customer_cim_id, :customer_payment_profile_id => paymentprofile.payment_cim_id, :validation_mode => :test)
          if response.success?
            response = gateway.create_customer_profile_transaction({:transaction => {:type => :auth_capture,
                  :amount => subscription.amount,
                  :customer_profile_id =>  user.customer_cim_id,
                  :customer_payment_profile_id => paymentprofile.payment_cim_id, :recurringBilling => true}})
            if response.success?
              alphanumerics = [('0'..'9'),('A'..'Z'),('a'..'z')].map {|range| range.to_a}.flatten
              make_invoice_number = (0...6).map { alphanumerics[Kernel.rand(alphanumerics.size)] }.join
              subretries = SubscriptionRetry.find_all_by_subscription_id(subscription.id)
              subretries.each do |s|
                s.destroy
              end      
              transaction_id = response.params['direct_response']['transaction_id']        
              inv = Invoice.new
              inv.invoice_type = "monthly subscription fees"
              inv.amount = subscription.amount
              inv.subscription_id = subscription.id
              inv.user_id = user.id
              inv.number = transaction_id
              inv.settled = true
              inv.save
              trans = Transaction.new
              trans.confirmation_id = response.authorization
              trans.invoice_id = inv.id
              trans.save

              sub = Subscription.find(subscription.id)
              payment_on = sub.payment_on
              next_payment_on = payment_on.to_time.advance(:days => 1).to_date
              sub.payment_on = next_payment_on
              sub.save
            else
              alphanumerics = [('0'..'9'),('A'..'Z'),('a'..'z')].map {|range| range.to_a}.flatten
              make_invoice_number = (0...6).map { alphanumerics[Kernel.rand(alphanumerics.size)] }.join
              transaction_id = response.params['direct_response']['transaction_id']        
               inv = Invoice.new
              inv.invoice_type = "transaction failed"
              inv.amount = subscription.amount
              inv.subscription_id = subscription.id
              inv.user_id = user.id
              inv.number = transaction_id
              inv.settled = false
              inv.save

              trans = Transaction.new
              trans.error = !response.success?
              trans.error_code = response.params['messages']['message']['code']
              trans.error_message = response.params['messages']['message']['text']
              trans.invoice_id = inv.id
              trans.save


              subretry = SubscriptionRetry.new
              subretry.subscription_id = subscription.id
              subretry.retry_count = sretry.retry_count + 1
               if subretry.retry_count <= 3
                subretry.retry_on = Time.now.to_time.advance(:days => 1).to_date
              else
                Notifier.deliver_inform_unpaid(user)

              end
              subretry.save
            end
          end
        end
      end
    end
    
    puts "send cron email again"
end