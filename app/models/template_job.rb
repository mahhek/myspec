class TemplateJob < ActiveRecord::Base
  attr_accessible :name, :state, :start_date, :due_date, :job_id, :description, :id
  validates_presence_of :name, :message => "can't be blank"
  #validates_uniqueness_of :name, :message => "must be unique"
  has_many :template_specifications
  has_many :job
  belongs_to :user
end
