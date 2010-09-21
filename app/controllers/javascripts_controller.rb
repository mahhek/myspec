class JavascriptsController < ApplicationController
  before_filter :login_required
  access_control do
       allow logged_in
       
  end
  def dynamic_contacts
    @contacts = Contact.all
  end
  
  def dynamic_sections
    @sections = Section.all
  end
  
  def dynamic_charge
    @sub = Subscription.find_by_user_id(current_user.id)
  end
  
  def dynamic_select
    
  end
  
  def dinamic_select_2
    
  end
  
  def reason
    
  end
  
  def evaluator_reason
    
  end
  
  def notification
    @collaborator = Collaborator.find_by_email(current_user.email, :conditions => { :status => "invited"})
  end
  
  def standard_notes
    
  end
  
  def payment_info
    
  end
end
