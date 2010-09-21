class TemplateSpecificationSection < ActiveRecord::Base
  belongs_to :template_specification
  belongs_to :section
end
