class UserParagraph < ActiveRecord::Base
  attr_accessible :user_id, :part_article_id, :paragraph, :name, :user_article_id
  validates_presence_of :paragraph, :message => "can't be blank"
  belongs_to :user_article
  belongs_to :user
  belongs_to :part_article
  has_many :user_subparagraphs, :dependent => :destroy
end
