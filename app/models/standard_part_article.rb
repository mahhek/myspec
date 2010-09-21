class StandardPartArticle < ActiveRecord::Base
  attr_accessible :part_id, :article_id, :standard_section_id
  belongs_to :article
  belongs_to :standard_section
  has_many :standard_article_paragraphs, :dependent => :destroy
  has_many :standard_user_paragraphs, :dependent => :destroy
  accepts_nested_attributes_for :standard_article_paragraphs
end
