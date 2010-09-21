class SectionNote < ActiveRecord::Base
  attr_accessible :specification_section_id, :user_id, :title, :note
  belongs_to :user
  belongs_to :specification_section
  validates_presence_of :title, :on => :create, :message => "can't be blank"
end
