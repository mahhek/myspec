class StandardSubparagraph < ActiveRecord::Base
  attr_accessible :standard_article_paragraph_id, :description
  validates_presence_of :description, :message => "can't be blank"
  belongs_to :user
  belongs_to :standard_article_paragraph
end
