class ContactsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager, :except => [:destroy]
  end
  def index
    @contacts = Contact.all
  end
  
  def new
    @client = Client.find(params[:client_id])
    @contact = Contact.new(:client_id => params[:client_id])
  end
  
  def create
    @contact = Contact.new(params[:contact])
    @client = Client.find(params[:contact][:client_id])
    if @contact.save
      flash[:notice] = "Contact successfully created."
      redirect_to client_path(@contact.client_id)
    else
      params[:client_id] = @client.id
      render :action => 'new'
    end
  end
  
  def edit
    @contact = Contact.find(params[:id])
    @client = @contact.client
  end
  
  def update
    @contact = Contact.find(params[:id])
    @client = @contact.client
    if @contact.update_attributes(params[:contact])
      flash[:notice] = "Contact successfully updated."
      redirect_to client_path(:id => @contact.client.id)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @contact = Contact.find(params[:id])
    id= @contact.client_id
    @contact.destroy
    flash[:notice] = "Contact successfully removed."
    redirect_to client_path(id)
  end
end
