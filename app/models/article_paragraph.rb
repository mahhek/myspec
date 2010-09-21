class ArticleParagraph < ActiveRecord::Base
  attr_accessible :part_article_id, :paragraph_id
  belongs_to :paragraph
  belongs_to :part_article
  has_many :subparagraphs, :dependent => :destroy
  accepts_nested_attributes_for :subparagraphs
end
