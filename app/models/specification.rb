class Specification < ActiveRecord::Base
  attr_accessible :job_id, :division_id
  belongs_to :job
  belongs_to :division
  has_many :specification_sections, :dependent => :destroy
end
