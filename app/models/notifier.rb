class Notifier < ActionMailer::Base  
  default_url_options[:host] = "myspecdata.com"

  def initial_try_failed(user)
       subject       "My SpecWriter Payment Declined"
       from          "noreply@myspecdata.com"
       recipients    user.email
#       recipients    "support@myspecdata.com"
#       recipients    "mahhek.khan@gmail.com"
       sent_on       Time.now
       body          :user =>  user
  end

  def inform_unpaid(user)
       subject       "Trasaction failed"
       from          "noreply@myspecdata.com" 
       recipients    "support@myspecdata.com"
#       recipients    "mahhek.khan@gmail.com"
       sent_on       Time.now
    
       body          :user =>  user
  end
  
  def activate_user(user)
       subject       "Account Reactivated"
       from          "noreply@myspecdata.com" # Removed name/brackets around 'from' to resolve "555 5.5.2 Syntax error." as of Rails 2.3.3
       recipients    user.email
       sent_on       Time.now
  end

  def suspend_user(user)
       subject       "My SpecWriter account suspension"
       from          "noreply@myspecdata.com" # Removed name/brackets around 'from' to resolve "555 5.5.2 Syntax error." as of Rails 2.3.3
       recipients    user.email
       sent_on       Time.now
  end

  def activation_instructions(user)
       subject       "Activation Instructions"
       from          "noreply@myspecdata.com" # Removed name/brackets around 'from' to resolve "555 5.5.2 Syntax error." as of Rails 2.3.3
       recipients    user.email #"support@myspecdata.com" #intercept
       sent_on       Time.now
       content_type  "text/html"
       body          :account_activation_url => activate_url(user.perishable_token), :user => user
  end
  
  def new_user(user)
      subject       "New User Registration"
      from          "noreply@myspecdata.com" # Removed name/brackets around 'from' to resolve "555 5.5.2 Syntax error." as of Rails 2.3.3
      recipients    user.email #intercept"sabril.odesk@gmail.com"#"support@myspecdata.com" #intercept
      sent_on       Time.now
      content_type  "text/html"
      body          :user => user
  end
  
  def password_reset_instructions(user)  
    subject       "Password Reset Instructions"  
    from          "noreply@myspecdata.com"  
    recipients    user.email#"support@myspecdata.com"#
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)  
  end 
  
  def password_set_instructions(user)  
    subject       "You have been added as a team member"  
    from          "noreply@myspecdata.com"  
    recipients    user.email #"support@myspecdata.com"
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token), :user => user  
  end 
  
  def welcome(user)
    subject       "Welcome to Spec Writer!"
    from          "noreply@myspecdata.com"
    recipients    user.email
    sent_on       Time.now
    body          :root_url => root_url
  end
    
  def reset_success(user)
    subject       "Your password has been changed"
    from          "noreply@myspecdata.com"
    recipients    user.email
    sent_on       Time.now
    body          :login_url => login_url
  end
    
    def help_ticket(ticket)
      subject       "New Help Ticket!"
      from          "noreply@myspecdata.com"
      recipients    "support@myspecdata.com"
      sent_on       Time.now
      body          :ticket => ticket
      content_type  "text/html"
    end
    
    def section_request(request)
      subject       "New Section Request"
      from          "noreply@myspecdata.com"
      recipients    "supportk@myspecdata.com"
      sent_on       Time.now
      body          :request => request
      content_type  "text/html"
    end
    
    def section_request_success(request)
      subject       "Your help ticket status has been updated"
      from          "support@myspecdata.com"
      recipients    request.user.email
      sent_on       Time.now
      content_type  "text/html"
      body          :request => request
    end
    
    def help_success(ticket)
      subject       "Your help ticket has been submitted"
      from          "support@myspecdata.com"
      recipients    ticket.user.email
      sent_on       Time.now
      content_type  "text/html"
      body          :ticket => ticket
    end
    
    def evaluator_invitation(user)
      subject       "You have been invited to be an evaluator"
      from          "support@myspecdata.com"
      recipients    user.email
      sent_on       Time.now
      #content_type  "text/html"
      body          :user => user, :edit_password_reset_url => edit_password_reset_url(user.perishable_token)  
    end
    
    def evaluator_request(request)
      subject       "New Evaluator Request"
      from          request.user.email
      recipients    "support@myspecdata.com"
      sent_on       Time.now
      content_type  "text/html"
      body          :request => request
    end
    
    def evaluator_request_update(request)
      subject       "Your request status has been updated"
      from          "support@myspecdata.com"
      recipients    request.user.email
      sent_on       Time.now
      content_type  "text/html"
      body          :request => request
    end
    
    #collaborator
    def collaborator_invitation(collaborator)
      subject       "You have been invited to be a collaborator"
      from          "support@myspecdata.com"
      recipients    collaborator.email
      sent_on       Time.now
      content_type  "text/html"
      body          :collaborator => collaborator, :login_url => login_url
    end
      
    def new_user_collaborator(collaborator)
      subject       "You have been invited to be a collaborator"
      from          "support@myspecdata.com"
      recipients    collaborator.email
      sent_on       Time.now
      content_type  "text/html"
      body          :collaborator => collaborator, :verify_collaborator_url => verify_collaborator_url(:token => collaborator.token)
    end

    #professional
    def professional_sent(professional)
      subject "Information submitted to My SpecWriter"
      from "support@myspecdata.com"
      recipients professional.email
      sent_on Time.now
      url = "http://myspecdata.com/verify/#{professional.token}"
      body :professional => professional, :url => url
    end

    def professional_pending(professional)
      subject "Information reviewed by My SpecWriter"
      from "support@myspecdata.com"
      recipients professional.email
      sent_on Time.now
    end

    def professional_accepted(professional)
      subject "Information accepted by My SpecWriter"
      from "support@myspecdata.com"
      recipients professional.email
      sent_on Time.now
    end

    def professional_rejected(professional, reason_rejection)
      subject "Information rejected by My SpecWriter"
      from "support@myspecdata.com"
      recipients professional.email
      sent_on Time.now
      body :reason_rejection => reason_rejection
    end

    def professional_developer(professional)
      subject "Information accepted by My SpecWriter"
      from "support@myspecdata.com"
      recipients "support@myspecdata.com"
      sent_on Time.now
      body :professional => professional
    end
    
    def cancel_subscription(user)
      subject       "Your account has been cancelled."
      from          "support@myspecdata.com"
      recipients    user.email
      sent_on       Time.now
      content_type  "text/html"
      body          :user => user
    end
    
    def prorate(num_user_bill, num_pro_bill, num_space_bill, user)
      subject       "Your account has been cancelled."
      from          "support@myspecdata.com"
      recipients    "admin@myspecdata.com"#user.email
      sent_on       Time.now
      #content_type  "text/html"
      body          :user => user, :num_user_bill => num_user_bill, :num_pro_bill => num_pro_bill, :num_space_bill => num_space_bill
    end
end