class SectionRequest < ActiveRecord::Base
  #attr_accessible :number, :name, :description, :user_id, :proposal_type, :supporting_rationale
  belongs_to :user
  has_attached_file :req,
                    :storage => :cloud_files, 
                    :cloudfiles_credentials => "#{RAILS_ROOT}/config/rackspace_cloudfiles.yml"
  
  #validates_attachment_presence :req
  #validates_attachment_size :req, :less_than => 300.kilobytes, :message => "must be less than 2MB"
  #validates_attachment_content_type :req, :content_type => ["application/pdf"], :message => "must be a PDF file"
  
  def deliver_section_request!
    Notifier.deliver_section_request(self)
  end
  
  def deliver_section_request_success!
    Notifier.deliver_section_request_success(self)
  end
end
