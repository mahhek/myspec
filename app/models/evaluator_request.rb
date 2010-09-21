class EvaluatorRequest < ActiveRecord::Base
  attr_accessible :user_id, :description, :reason, :status, :prefix, :first_name, :last_name, :middle_name, :csi_member, :title, :firm, :address, :city, :state, :zip, :phone, :fax, :email
  belongs_to :user
  validates_presence_of :first_name, :csi_member
  
  def deliver_evaluator_request!
    Notifier.deliver_evaluator_request(self)
  end
  
  def deliver_evaluator_request_update!
    Notifier.deliver_evaluator_request_update(self)
  end
end
