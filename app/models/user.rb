class User < ActiveRecord::Base
  #attr_accessible :login, :email, :password, :password_confirmation, :id, :parent_id, :first_name, :last_name, :company, :position, :telephone, :username, :roles, :fax, :address
    has_many :invoices
	  belongs_to :subscription
	  belongs_to :payment_profile
    has_one :credit_card_information
  attr_protected :active
  acts_as_tree :order => "first_name"
  has_many :clients
  has_many :section_attachments
  has_many :section_documents
  has_many :section_notes
  has_many :subparagraphs, :dependent => :destroy
  has_many :standard_subparagraphs, :dependent => :destroy
  has_one :billing_plan, :dependent => :destroy
  has_many :help_tickets, :dependent => :destroy
  has_many :subscription_histories
  has_one :admin_format
  has_many :section_requests, :dependent => :destroy
  has_many :template_jobs
  has_many :user_paragraphs, :dependent => :destroy
  has_many :user_subparagraphs, :dependent => :destroy
  has_many :standard_user_paragraph, :dependent => :destroy
  has_many :standard_user_subparagraphs, :dependent => :destroy
  has_one :evaluator_request, :dependent => :destroy
  has_many :standard_user_articles, :dependent => :destroy
  has_many :standard_section_notes, :dependent => :destroy
  has_many :collaborators, :dependent => :destroy
  has_many :specification_section
  has_many :subscriptions, :dependent => :destroy
  
  validates_uniqueness_of :username, :message => "Username exists"
   #validates_presence_of :first_name, :on => :update, :message => "can't be blank"
#    validates_presence_of :company, :on => :update, :message => "can't be blank"
  # validates_presence_of :address, :on => :update, :message => "can't be blank"
  # validates_presence_of :city, :on => :update, :message => "can't be blank"
  # validates_presence_of :state, :on => :update, :message => "can't be blank"
  # validates_presence_of :zip, :on => :update, :message => "can't be blank"
  # validates_presence_of :country, :on => :update, :message => "can't be blank"
#    validates_presence_of :telephone, :on => :update, :message => "can't be blank"

  #validates_presence_of :password, :message => "Password cannot be blank"
  
  belongs_to :layout
  acts_as_authentic do |c|
    c.logged_in_timeout = 4.hours
    c.login_field = :username
  end
  acts_as_authorization_subject  :association_name => :roles
  def deliver_test!
    u = User.find(1)
    Notifier.deliver_welcome(u)
  end
    def user_profile
	    return {:merchant_customer_id => self.id, :email => self.email, :description => self.username}
	  end
	  
  
  def full_name
    if self.first_name.nil?
      self.first_name = ""
    end
    first_name
  end

  def is_unpaid?
    unless self.has_role?(:developer)
    if current_billing > 0 
      sub = Subscription.find_by_user_id(self.id)
      if sub.blank? && !self.has_role?(:owner)
        return true
      end
    end
    return false
    else
      return false
    end
  end
  
  def member_stat_count
    if self.max_member == 1
      member_stat_count = 100
    else
      member_stat_count = ((self.total_member.to_f) / self.max_member.to_f) * 100
    end
  
  end
  def member_stat
    if self.max_member == 1
      member_stat = "over"
    else
      if member_stat_count.to_f < 50.0
        member_stat = "below"
      elsif (member_stat_count.to_f >= 50.0 && member_stat_count < 100)
        member_stat = "reaching"
      elsif member_stat_count >= 100
        member_stat = "over"
      end
    end
    return member_stat
  end
  
  def storage_count
    section_attachments_size = SectionAttachment.specification_section_specification_job_client_user_id_eq(self.id).sum(:asset_file_size)
    section_documents_size = SectionDocument.specification_section_specification_job_client_user_id_eq(self.id).sum(:doc_file_size)
    storage_count = section_documents_size + section_attachments_size
    return storage_count
  end
  
  def storage_percentage
    percentage = (((self.storage_count.to_f/5368709120)).round(2) * 100)
    if percentage < 0
      percentage = 0
    end
    return percentage
  end
  
  def storage_stat
    if self.storage_percentage < 50.0
      storage_stat = "below"
    elsif (storage_percentage >= 50.0 && storage_percentage < 100)
      storage_stat = "reaching"
    elsif storage_percentage >= 100
      storage_stat = "over"
    end
  end

  def current_billing_professional
     if self.has_role?(:owner) && self.billing_plan.plan_type_id != 1
       if (self.billing_plan.number_of_professional.blank?) || (self.billing_plan.number_of_professional == 0)
         current_billing_professional = 0
       else
         current_billing_professional = 10
       end
     else
       current_billing_professional = 0
     end
     return current_billing_professional
  end
  
  def current_storage_billing
     if self.has_role?(:owner) && self.billing_plan.plan_type_id == 2
      unless self.billing_plan.number_of_space.blank?
      if self.billing_plan.number_of_space > 5
       current_storage_billing = (self.billing_plan.number_of_space - 5) / 5 * 2
       else
         current_storage_billing = 0
       end
      else
         current_storage_billing = 0
      end
     elsif self.has_role?(:owner) && self.billing_plan.plan_type_id == 1
       current_storage_billing = 0
     elsif self.has_role?(:owner) && self.billing_plan.plan_type_id == 3
       current_storage_billing = 0
    end
  end
  
  def current_billing
    #change this if stable
    if self.has_role?(:owner) && self.billing_plan.plan_type_id != 1
      if !self.has_role?(:evaluator)
        current_billing =  self.billing_plan.number_of_user * 10
      else
        current_billing =  (self.billing_plan.number_of_user - 2) * 10
      end
    else
      current_billing = 0
    end
  end
  
  def total_member
    users = User.find_by_sql("select * from users where parent_id = #{self.id} and is_archive = 0")
    total = users.size
    total = total + 1
  end
  
  def max_member
    max_member = self.billing_plan.number_of_user
  end
  
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Notifier.deliver_password_reset_instructions(self)  
  end
  
  def deliver_password_set_instructions!  
    reset_perishable_token!  
    Notifier.deliver_password_set_instructions(self)  
  end
  
  def activate!
    self.active = true
    save
  end
  
  def deliver_activation_instructions!
      reset_perishable_token!
      Notifier.deliver_activation_instructions(self)
      Notifier.deliver_new_user(self)
    end

    def deliver_welcome!
      reset_perishable_token!
      Notifier.deliver_welcome(self)
    end
    
     def deliver_reset_success!
        reset_perishable_token!
        Notifier.deliver_reset_success(self)
      end

      def deliver_evaluator_invitation!  
        reset_perishable_token!  
        Notifier.deliver_evaluator_invitation(self)  
      end
      def deliver_cancel_subscription!
        reset_perishable_token!
        Notifier.deliver_cancel_subscription(self)
      end
      
      
end
