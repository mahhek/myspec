class Paragraph < ActiveRecord::Base
  attr_accessible :part_id, :article_id, :name, :description#, :number
  #validates_presence_of :number, :message => "can't be blank"
  #validates_uniqueness_of :number, :message => "must be unique"
  
  belongs_to :part
  belongs_to :article
  has_many :article_paragraphs, :dependent => :destroy
end
