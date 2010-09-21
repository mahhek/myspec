class HelpTicket < ActiveRecord::Base
  attr_accessible :user_id, :title, :description, :mood, :parent_id
  belongs_to :user

  validates_presence_of :title
  validates_presence_of :description
#  validates_precense_of :mood
  
  def deliver_help_ticket!
    Notifier.deliver_help_ticket(self)
  end
  
  def deliver_help_success!
    Notifier.deliver_help_success(self)
  end

  def auto_number
    str_id = self.id.to_s
    remaining_zero = 12 - str_id.length
    auto_number = "S" + "0" * remaining_zero + str_id
    return auto_number
  end
end
