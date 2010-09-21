class SupportsController < ApplicationController
  before_filter :login_required, :warning
  access_control do
       allow :admin, :to => [:new, :create]
       allow :manager, :to => [:new, :create]
       allow :support
  end
  def index
    
  end
end
