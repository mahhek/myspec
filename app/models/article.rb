class Article < ActiveRecord::Base
  attr_accessible :name, :description, :part_category, :number
  validates_presence_of :number, :message => "can't be blank"
  #validates_uniqueness_of :number, :message => "must be unique"
  has_many :part_articles
  has_many :paragraphs
end
