class SpecificationSection < ActiveRecord::Base
  #attr_accessible :specification_id, :section_id
  belongs_to :specification
  belongs_to :section
  belongs_to :user
  has_many :part_articles
  has_many :articles, :through => :part_articles
  has_many :standard_sections, :dependent => :destroy
  has_many :section_attachments, :dependent => :destroy
  has_many :section_notes, :dependent => :destroy
  has_many :user_articles, :dependent => :destroy
  accepts_nested_attributes_for :part_articles, :allow_destroy => true
  accepts_nested_attributes_for :articles, :allow_destroy => true
  accepts_nested_attributes_for :user_articles
  def date_update
    updated_at.strftime("%m-%d-%Y")
  end
  
  def options
    options = ["job no","date", "job name", "job location", "section author", "section name", "section no", "page no", "section no - page no"]
  end
  
  def choose_option(option,pdf=nil)
    if (options.include?(option))
      if option == "job no"
        choosen = self.specification.job.number
      elsif option == "date"
        choosen = Time.now.strftime("%m-%d-%Y")
      elsif option == "job name"
        choosen = self.specification.job.name
      elsif option == "job location"
         if self.specification.job.city.nil?
          self.specification.job.city = ""
        end
        if self.specification.job.state.nil?
          self.specification.job.state = ""
        end

        choosen = self.specification.job.city + ", " + self.specification.job.state
        
      elsif option == "section author"
        choosen = self.specification.job.client.user.username
      elsif option == "section name"
        choosen = self.section.name
      elsif option == "section no"
        choosen = self.section.modif_number
      elsif option == "page no"
        choosen = "Page #{pdf.page_number}"
      elsif option == "section no - page no"
        choosen = "#{self.section.modif_number} - #{pdf.page_number}"
      end
    else
      choosen = option
    end
    return choosen.to_s
  end
  
end
