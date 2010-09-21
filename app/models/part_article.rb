class PartArticle < ActiveRecord::Base
  attr_accessible :part_id, :article_id, :specification_section_id
  belongs_to :part
  belongs_to :article
  belongs_to :specification_section
  has_many :article_paragraphs, :dependent => :destroy#, :finder_sql => 'SELECT ap.* FROM `article_paragraphs` ap left outer join paragraphs p on ap.paragraph_id = p.id WHERE (ap.part_article_id = #{self.id}) order by p.number ASC'
  
  #, :finder_sql => 'select * from article_paragraphs ap left outer join paragraphs p on ap.paragraph_id=p.id where ap.part_article_id = #{self.id}'
  has_many :user_paragraphs, :dependent => :destroy
  accepts_nested_attributes_for :article_paragraphs
end
