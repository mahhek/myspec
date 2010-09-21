class Collaborator < ActiveRecord::Base
  attr_accessible :user_id, :email, :status, :token, :job_ids
  belongs_to :user
  has_many :shares, :dependent => :destroy
  has_many :jobs, :through => :shares
  validates_presence_of :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_presence_of :token
  validates_uniqueness_of :token
  validate :job_selected?
  validate_on_create :email_is_valid?
  validate_on_create :duplicate_share?
  
  def send_invitation!
      Notifier.deliver_collaborator_invitation(self)
  end
  
  protected
  
  def before_validation_on_create
      self.token = rand(36**8).to_s(36) if self.new_record? and self.token.nil?
  end
  
  private
  
  def job_selected?
    if self.jobs.size == 0
      errors.add_to_base("No job selected")
    end
  end
  
  def email_is_valid?
    if self.email == as_user.email || self.user.email == self.email
      errors.add_to_base("Email is not valid")
    end
  end
  
  def as_user
    if self.user.has_role?(:owner)
      as_user = self.user
    else
      as_user = self.user.parent
    end
  end
  
  def duplicate_share?
    c = 0
    for collaborator in self.user.collaborators
      if collaborator.email == self.email
        c += 1
      end
    end
    if c > 0
      errors.add_to_base("You have added this email")
    end
  end
end
