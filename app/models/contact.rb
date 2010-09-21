class Contact < ActiveRecord::Base
  attr_accessible :client_id, :name, :position, :phone, :mobile, :email, :id
  belongs_to :client
  has_many :jobs
  validates_presence_of :name, :message => "can't be blank"
  validates_presence_of :email, :message => "can't be blank"
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
end
