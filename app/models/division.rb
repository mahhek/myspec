class Division < ActiveRecord::Base
  attr_accessible :name, :division_number
  validates_presence_of :name, :message => "Division name can't be blank"
  validates_presence_of :division_number, :message => "Division number can't be blank"
  has_many :specifications
  has_and_belongs_to_many :professionals
  def short_number
    if(division_number[0,1] != "0")
      div_number = division_number[0,2]
    else
      div_number = division_number[1,1]
    end
  end
  
  def search_number
    search_number = short_number
    if search_number.length == 1
      search_number = "0#{search_number}"
    else
      search_number = short_number
    end
  end
  
  
  def modif_number
       a = division_number[0,2]
       b = division_number[2,2]
       c = division_number[4,2]
       
    return "#{a} #{b} #{c}"
  end
end
