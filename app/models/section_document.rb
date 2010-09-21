class SectionDocument < ActiveRecord::Base
  #attr_accessible :specification_section_id, :user_id, :title, :note
  belongs_to :user
  belongs_to :specification_section
  has_attached_file :doc
  
  has_attached_file :doc,
                    :storage => :cloud_files, 
                    :cloudfiles_credentials => "#{RAILS_ROOT}/config/rackspace_cloudfiles.yml"
                  
  validates_presence_of :title
  validates_attachment_size :doc, :less_than => 1.megabytes, :message => "must be less than 1MB"
  validates_attachment_content_type :doc, :content_type => ["application/pdf"], :message => "must be a PDF file"
end
