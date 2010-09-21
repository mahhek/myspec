class StandardArticleParagraph < ActiveRecord::Base
  attr_accessible :standard_part_article_id, :paragraph_id
  belongs_to :paragraph
  belongs_to :standard_part_article
  has_many :standard_subparagraphs, :dependent => :destroy
  accepts_nested_attributes_for :standard_subparagraphs
end
