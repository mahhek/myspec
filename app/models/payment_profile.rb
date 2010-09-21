class PaymentProfile < ActiveRecord::Base
  
    include ActiveMerchant::Billing
    include ActiveMerchant::Utils
	  belongs_to :user

  
end
