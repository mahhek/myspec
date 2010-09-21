class SectionAttachment < ActiveRecord::Base
  #attr_accessible :specification_section_id, :title, :note
  belongs_to :specification_section
  belongs_to :user
  
  has_attached_file :asset,
                    :storage => :cloud_files, 
                    :cloudfiles_credentials => "#{RAILS_ROOT}/config/rackspace_cloudfiles.yml"

  validates_presence_of :title
  validates_attachment_presence :asset
  validates_attachment_size :asset, :less_than => 1.megabytes, :message => "must be less than 300KB"
  validates_attachment_content_type :asset, :content_type => ["application/pdf"], :message => "must be a PDF file"
  
  
end
