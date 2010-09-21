class UserSubparagraph < ActiveRecord::Base
  attr_accessible :user_id, :user_paragraph_id, :description
    validates_presence_of :description, :message => "can't be blank"
  belongs_to :user_paragraph
  belongs_to :user
end
