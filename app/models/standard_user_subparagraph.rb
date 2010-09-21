class StandardUserSubparagraph < ActiveRecord::Base
  attr_accessible :user_id, :standard_user_paragraph_id, :description
  validates_presence_of :description, :message => "can't be blank"
  belongs_to :user
  belongs_to :standard_user_paragraph
end
