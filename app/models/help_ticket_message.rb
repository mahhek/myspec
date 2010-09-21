class HelpTicketMessage < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :subject
  validates_presence_of :message
  
end
