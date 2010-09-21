class Client < ActiveRecord::Base
  acts_as_authorization_object
  attr_accessible :name, :account_manager, :physical_address, :postal_address, :phone, :fax, :website, :project_name, :project_description, :user_id, :status
  belongs_to :user
  has_many :jobs, :dependent => :destroy
  has_many :contacts, :dependent => :destroy
  validates_presence_of :name, :message => "can't be blank"
    # validates_presence_of :postal_address, :message => "can't be blank"
    # validates_presence_of :phone, :message => "can't be blank"
    # validates_presence_of :physical_address, :message => "can't be blank"
  
 
end
