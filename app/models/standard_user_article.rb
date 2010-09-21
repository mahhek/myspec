class StandardUserArticle < ActiveRecord::Base
  attr_accessible :user_id, :standard_section_id, :name, :description
  validates_presence_of :name, :message => "can't be blank"
  belongs_to :standard_section
  belongs_to :user
  
  has_many :standard_user_paragraphs, :dependent => :destroy
end
