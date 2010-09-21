class TemplateSpecification < ActiveRecord::Base
  attr_accessible :template_job_id, :division_id
  belongs_to :template_job
  belongs_to :division
  has_many :template_specification_sections, :dependent => :destroy
end
