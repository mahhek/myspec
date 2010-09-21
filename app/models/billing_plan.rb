class BillingPlan < ActiveRecord::Base
  attr_accessible :user_id, :plan_type_id, :number_of_user, :number_of_space
  belongs_to :user
  belongs_to :plan_type
  
  validates_presence_of :number_of_user
  validates_numericality_of :number_of_user, :greater_than_or_equal_to => 0
  
  
  
  

  
  
end