class SectionRequestsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin, :to => [:new, :create]
       allow :manager, :to => [:new, :create]
       allow :master
  end
  def index
    @section_requests = SectionRequest.status_does_not_equal("deny")
  end
  
  def show
    @section_request = SectionRequest.find(params[:id])
  end
  
  def new
    @section_request = SectionRequest.new(:user_id => current_user.id)
  end
  
  def create
    @section_request = SectionRequest.new(params[:section_request])
    @section_request.status = "received"
    @section_request.user_id = current_user.id
    if @section_request.save
      @section_request.deliver_section_request!
      flash[:notice] = "Your Section Request has been submitted. Thank you."
      redirect_to new_section_request_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @section_request = SectionRequest.find(params[:id])
  end
  
  def update
    @section_request = SectionRequest.find(params[:id])
    if @section_request.update_attributes(params[:section_request])
      @section_request.deliver_section_request_success!
      flash[:notice] = "Successfully updated section request."
      redirect_to @section_request
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @section_request = SectionRequest.find(params[:id])
    @section_request.destroy
    flash[:notice] = "Successfully removed section request."
    redirect_to section_requests_url
  end
  
  def download
    @attachment = SectionRequest.find(params[:id])
    @ccf = CloudFiles::Connection.new(CLOUD_CONFIG['username'],CLOUD_CONFIG['api_key'])
    container = @ccf.container(CLOUD_CONFIG['container'])
    object = container.object(@attachment.req.path)
    tmp = File.open(RAILS_ROOT + "/tmp/downloads/"+@attachment.req_file_name, "w+")
    tmp.syswrite(object.data)
    #render :url => object.public_url
    #puts tmp.path
    send_file(tmp.path,
                :disposition => 'inline',
               :encoding => 'utf8', 
               :type => object.content_type,
               :filename => URI.encode(@attachment.req_file_name))
    # @attachment = SectionRequest.find(params[:id])
    #     send_file(@attachment.req.path,:disposition => 'inline',
    #           :encoding => 'utf8', 
    #           :type => @attachment.req_content_type,
    #           :filename => URI.encode(@attachment.req_file_name))
  end
end
