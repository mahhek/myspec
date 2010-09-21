class StandardUserParagraph < ActiveRecord::Base
  attr_accessible :user_id, :standard_part_article_id, :name, :paragraph, :standard_user_article_id
  validates_presence_of :paragraph, :message => "can't be blank"
  belongs_to :user
  belongs_to :standard_part_article
  belongs_to :standard_user_article
  has_many :standard_user_subparagraphs, :dependent => :destroy
end
