class Job < ActiveRecord::Base
  attr_accessible :client_id, :name, :state, :start_date, :due_date, :job_type, :number, :contact_id, :po_number, :description, :template_job_id, :address, :job_page_format, :text, :status, :city
  acts_as_authorization_object
  validates_presence_of :name, :message => "can't be blank"
  validates_presence_of :client_id, :message => "can't be blank, choose a client"
  validates_presence_of :contact_id, :message => "can't be blank, choose a contact or create one"
  validates_presence_of :number, :message => "can't be blank"
  validates_presence_of :status, :message => "can't be blank"
  validate_on_create :job_quota_ready
  #validates_presence_of :template_job_id, :message => "you have to choose a template"
  
  belongs_to :client
  belongs_to :contact
  belongs_to :template_job
  has_many :shares
  has_many :collaborators, :through => :shares
  has_many :specifications #, :dependent => :destroy => don't need this to make template job works
  has_one :job_page_format
  
  
  def job_attributes=(specification_attributes)
    specification_attributes.each do |attributes|
      specifications.build
    end
  end

    def options
    options = ["job no","date", "job name", "job location", "section author", "section name", "section no", "page no", "section no - page no"]
  end

  def choose_option(option,pdf=nil)
    if (options.include?(option))
      if option == "job no"
        choosen = self.number
      elsif option == "date"
        choosen = Time.now.strftime("%m-%d-%Y")
      elsif option == "job name"
        choosen = self.name
      elsif option == "job location"
        if self.city.nil?
          self.city = ""
        end
        if self.state.nil?
          self.state = ""
        end
        choosen = self.city + ", " + self.state
      elsif option == "section author"
        choosen = ""
      elsif option == "section name"
        choosen = ""
      elsif option == "section no"
        choosen = ""
      elsif option == "page no"
        choosen = "Page #{pdf.page_number}"
      elsif option == "section no - page no"
        choosen = ""
      end
    else
      choosen = option
    end
    return choosen.to_s
  end

  private 
  def job_quota_ready
    if as_user.billing_plan.plan_type_id == 1 && job_counter >= 3
      errors.add_to_base("Your job quota is 3 for free user, please upgrade your subscription plan")
    end
  end
  
  def as_user
    if self.client.user.has_role?(:owner)
      as_user = self.client.user
    else
      as_user = self.client.user.parent
    end
  end
  
  def job_counter
    job_counter = 0
    for client in as_user.clients
      job_counter = job_counter + client.jobs.count
    end
    return job_counter
  end
end
