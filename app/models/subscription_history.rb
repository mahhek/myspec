class SubscriptionHistory < ActiveRecord::Base
  attr_accessible :due_on, :description, :amount, :user_id, :status
  
  # def paypal_url(return_url)
  #     values = {
  #         :business => 'suppor_1279211228_biz@myspecdata.com',
  #         :cmd => '_cart',
  #         :upload => 1,
  #         :return => return_url,
  #         :invoice => id
  #       }
  #       
  #         values.merge!({
  #           "amount_1" => self.amount,
  #           "item_name_1" => self.description,
  #           "item_number_1" => self.id,
  #           "quantity_1" => 1
  #         })
  #       
  #       "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
  #   end
end
