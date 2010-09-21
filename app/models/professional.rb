class Professional < ActiveRecord::Base

  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :physical_address
  validates_presence_of :telephone
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_uniqueness_of :email
  validates_format_of :website, :with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\Z/ix, :if => :website?
  has_and_belongs_to_many :certifications
  has_and_belongs_to_many :divisions

# Paperclip
    has_attached_file :logo,
        :styles => {
        :small  => "230x50>" },
                    :storage => :cloud_files,
                    :cloudfiles_credentials => "#{RAILS_ROOT}/config/rackspace_cloudfiles.yml"

#  validates_attachment_content_type :logo, :content_type => 'image/gif'
end
