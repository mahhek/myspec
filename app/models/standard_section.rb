class StandardSection < ActiveRecord::Base
  attr_accessible :specification_section_id, :standard_name, :user_id, :keywords, :comments, :section_id, :id
  belongs_to :specification_section
  belongs_to :section
  belongs_to :user
  has_many :standard_user_articles, :dependent => :destroy
  has_many :standard_section_notes, :dependent => :destroy
  validates_presence_of :standard_name, :message => "Standard Name cannot be blank"

  def options
    options = ["job no","date", "job name", "job location", "section author", "section name", "section no", "page no", "section no - page no"]
  end

  def choose_option(option,pdf=nil)
    if (options.include?(option))
      if option == "job no"
        choosen = ""
      elsif option == "date"
        choosen = self.created_at.strftime("%m-%d-%Y")
      elsif option == "job name"
        choosen = ""
      elsif option == "job location"
        choosen = ""
      elsif option == "section author"
        choosen = self.user.full_name
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