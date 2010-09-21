class Section < ActiveRecord::Base
  attr_accessible :number, :name
  validates_presence_of :name, :message => "Section name can't be blank"
  validates_presence_of :number, :message => "Section number can't be blank"
  has_many :specification_section
  has_many :see_sections
  has_many :see_also_sections
  
  def division_number
    a = number[0,2]
  end
  
  def division_search
    a = number
  end
  
  def modif_number
    if number.length == 9
       a = number[0,2]
       b = number[2,2]
       c = number[4,2]
       d = number[6,3]
    else
        a = number[0,2]
        b = number[2,2]
        c = number[4,2]
        d = number[6,2]
    end
    return "#{a} #{b} #{c} #{d}"
  end
  
  def report_number
    if number.length == 9
       a = number[0,2]
       b = number[2,2]
       c = number[4,2]
       d = number[6,3]
    else
        a = number[0,2]
        b = number[2,2]
        c = number[4,2]
        d = number[6,2]
    end
    return "#{a} #{b}#{c}#{d}"
  end
end
