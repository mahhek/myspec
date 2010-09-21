class UserArticle < ActiveRecord::Base
  attr_accessible :user_id, :part_id, :name, :description, :specification_section_id

  validates_presence_of :name, :message => "can't be blank"
  
  belongs_to :user
  belongs_to :specification_section
  
  has_many :user_paragraphs, :dependent => :destroy
end
