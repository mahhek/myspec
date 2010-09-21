class StandardSectionNote < ActiveRecord::Base
  attr_accessible :standard_section_id, :user_id, :title, :description
  belongs_to :user
  belongs_to :standard_section
end
