class SectionAttachmentsController < ApplicationController
  require 'rubygems'
  require 'cloudfiles'
  require 'tempfile'
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager
       allow :team
  end
  
  def inc(specification_section_id)
     @specification_section = SpecificationSection.find(specification_section_id)
  end
  
  def index
    @job = Job.find(params[:job_id])
    @client = @job.client
    if params[:specification_section_id] != nil
      inc(params[:specification_section_id])
      @section_attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
      @section_attachment = SectionAttachment.new(:specification_section_id => @specification_section.id)
    else
      @section_attachments = SectionAttachment.specification_section_specification_job_id_eq(params[:job_id])
      @section_attachment = SectionAttachment.new
    end
  end
  
  def new
    # @job = Job.find(params[:job_id])
    #     @specification_section = SpecificationSection.find(params[:specification_section_id])
    #     @section_attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
    @section_attachments = SectionAttachment.specification_section_id_eq(params[:specification_section_id])
    @section_attachment = SectionAttachment.new(:specification_section_id => params[:specification_section_id])
  end
  
  def create
    @section_attachment = SectionAttachment.new(params[:section_attachment])
    @specification_section = SpecificationSection.find(@section_attachment.specification_section_id)
    @job = @specification_section.specification.job
    @client = @job.client
    @section_attachment.user_id = current_user.id
    if @section_attachment.save
      @specification_section.touch
      flash[:notice] = "Successfully created section attachment."
      redirect_to section_attachments_path(:job_id => @job.id, :specification_section_id => @specification_section.id, :collaborator_id => params[:collaborator_id])
    else
      render :action => 'new'
    end
  end
  
  def edit
    @job = Job.find(params[:job_id])
    @client = @job.client
    @specification_section = SpecificationSection.find(params[:specification_section_id])
    @section_attachments = SectionAttachment.specification_section_id_eq(@specification_section.id)
    @section_attachment = SectionAttachment.find(params[:id])
  end
  
  def update
    @section_attachment = SectionAttachment.find(params[:id])
    @specification_section = SpecificationSection.find( @section_attachment.specification_section_id)
    @job = @specification_section.specification.job
    @client = @job.client
    if @section_attachment.update_attributes(params[:section_attachment])
      @specification_section.touch
      flash[:notice] = "Successfully updated section attachment."
      redirect_to section_attachments_path(:job_id => @job.id, :specification_section_id => @specification_section.id)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @section_attachment = SectionAttachment.find(params[:id])
    @specification_section = SpecificationSection.find( @section_attachment.specification_section_id)
    @job = @specification_section.specification.job
    @client = @job.client
    @section_attachment.destroy
    @specification_section.touch
    flash[:notice] = "Section attachment successfully removed."
    redirect_to section_attachments_url(:job_id => @job.id, :specification_section_id => @specification_section.id)
  end
  
  def download
    @attachment = SectionAttachment.find(params[:id])
    @ccf = CloudFiles::Connection.new(CLOUD_CONFIG['username'],CLOUD_CONFIG['api_key'])
    container = @ccf.container(CLOUD_CONFIG['container'])
    object = container.object(@attachment.asset.path)
    tmp = File.open(RAILS_ROOT + "/tmp/downloads/"+@attachment.asset_file_name, "w+")
    tmp.syswrite(object.data)
    #render :url => object.public_url
    #puts tmp.path
    send_file(tmp.path,
                :disposition => 'inline',
               :encoding => 'utf8', 
               :type => object.content_type,
               :filename => URI.encode(@attachment.asset_file_name))
    #File.delete(tmp.path)
  end
end
