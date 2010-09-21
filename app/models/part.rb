class Part < ActiveRecord::Base
  attr_accessible :partName, :partDescription
  has_many :paragraphs
  has_many :spec_sec_parts, :dependent => :destroy
  has_many :part_articles
end
