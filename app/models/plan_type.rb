class PlanType < ActiveRecord::Base
  has_many :billing_plans
  def max_member
    if self.number_of_member == 1000
      max_member = "Unl"
    else
      max_member = self.number_of_member.to_s
    end
    return max_member
  end
  def max_job
    if self.number_of_job == 1000
      max_job = "Unl"
    else
      max_job = self.number_of_job.to_s
    end
    return max_job
  end
end
