class ClientsController < ApplicationController
  before_filter :login_required, :warning
  access_control do
      allow :admin
      allow :manager, :except => [:new, :create, :edit, :update, :destroy]
      allow :team, :to => [:index, :show]
  end
  def archived_client
    @clients = Client.is_archive_eq(true).user_id_eq(as_user).paginate(:per_page => 20, :page => params[:page])
  end

  def archive
    @client = Client.find(params[:id])
    @jobs = @client.jobs
    has_atleast_one_job = false

    unless @jobs.blank?
      @jobs.each do |job|
        unless job.is_archive
          has_atleast_one_job = true
        end
      end
    end
    if has_atleast_one_job
      flash[:notice] = "One or more jobs from this client are not archived."
      render :action => "edit", :id => @client.id
    else
    flash[:notice] = ""
    @client.is_archive = true
    @client.save
    redirect_to "/clients"
    end
    
  end
  
  def index
    @search = Client.search(params[:search])
    @clients = @search.is_archive_eq(false).user_id_eq(as_user).paginate(:per_page => 20, :page => params[:page])

  end
  
  def new
    @client = Client.new
  end
  
  def create
    @client = Client.new(params[:client])
    @client.user_id = as_user
    @contact = Contact.new(:name => params[:contact_name], :email => params[:contact_email])
    if @contact.save
      if @client.save
        @contact.client_id = @client.id
        @contact.save
        flash[:notice] = "Client successfully created."
        redirect_to client_path(@client)
      else
        flash[:warning] = "You need to fill data correctly."
        render :action => 'new'
      end
    else      
      flash[:warning] = "Contact name and email are required."
      render :new
    end
  end
  
  def edit
    @client = Client.find(params[:id])
  end
  
  def update
    @client = Client.find(params[:id])
    if @client.update_attributes(params[:client])
      flash[:notice] = "Client successfully updated."
      redirect_to client_path(@client)
    else
      render :action => 'edit'
    end
  end
  
  def show
    @client = Client.find(params[:id])
  end

  def destroy_archive_clients
    @client = Client.find(params[:id])
    @client.destroy
    flash[:notice] = "Client successfully removed."
    redirect_to "/clients/archived_client"
  end
  
  def destroy
    @client = Client.find(params[:id])
    if @client.jobs.count > 0
      flash[:warning] = "You need to delete all jobs before deleting this client."
    else
      @client.destroy
      flash[:notice] = "Client successfully removed."
    end
    redirect_to clients_path
  end
end
