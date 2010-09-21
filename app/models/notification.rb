class Notification < ActiveRecord::Base
  attr_accessible :title, :description, :due_on, :status
  validates_presence_of :title
  validates_presence_of :description

    def auto_number
      str_id = self.id.to_s
      remaining_zero = 12 - str_id.length
      auto_number = "N" + "0" * remaining_zero + str_id
      return auto_number
    end
end
