class Share < ActiveRecord::Base
  attr_accessible :job_id, :collaborator_id
  belongs_to :job
  belongs_to :collaborator
end
