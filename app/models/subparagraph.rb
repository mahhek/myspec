class Subparagraph < ActiveRecord::Base
  attr_accessible :article_paragraph_id, :description
  belongs_to :article_paragraph
  belongs_to :user
  validates_presence_of :description, :message => "can't be blank"
end
