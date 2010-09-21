class Layout < ActiveRecord::Base
  attr_accessible :name
  has_many :users
  has_many :admin_page_formats
  has_many :job_page_formats
end
