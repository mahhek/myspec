class SpecSecPart < ActiveRecord::Base
  attr_accessible :specification_section_id, :part, :section_id
  belongs_to :specification_section
end
