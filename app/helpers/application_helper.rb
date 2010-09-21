# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Acl9Helpers
  def as_user
    if current_user.has_role?(:owner)
      id = current_user.id
    else
      id = current_user.parent_id
    end
    return id
  end
  def report_article_number(number)
    if number.to_s.length == 1
      number = "0#{number}"
    end
    return number
  end
  
  def total_member
    total_member = current_user.children.count 
  end
end
