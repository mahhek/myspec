class SectionDocumentsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager
       allow :team
  end
  def inc(specification_section_id)
    @specification_section = SpecificationSection.find(specification_section_id)
    #@job = Job.find(@specification_section.specification.job)
  end
  
  def index
    @job = Job.find(params[:job_id])
    @client = @job.client
    if params[:specification_section_id] != nil
      inc(params[:specification_section_id])
      @section_documents = SectionDocument.specification_section_id_eq(@specification_section.id)
      @section_document = SectionDocument.new(:specification_section_id => @specification_section.id)
    else
      @section_documents = SectionDocument.specification_section_specification_job_id_eq(params[:job_id])
      @section_document = SectionDocument.new
    end
    
  end
  
  def new
    @section_document = SectionDocument.new
  end
  
  def create
    @section_document = SectionDocument.new(params[:section_document])
    inc(@section_document.specification_section_id)
    @job = @specification_section.specification.job
    @client = @job.client
    @section_document.user_id = current_user.id
    if @section_document.save
      @specification_section.touch
      flash[:notice] = "Successfully created section document."
      redirect_to section_documents_path(:job_id => @job.id, :specification_section_id => @specification_section.id, :collaborator_id => params[:collaborator_id])
    else
      render :action => 'new'
    end
  end
  
  def edit
    @section_document = SectionDocument.find(params[:id])
  end
  
  def update
    @section_document = SectionDocument.find(params[:id])
    inc(@section_document.specification_section_id)
    if @section_document.update_attributes(params[:section_document])
      @specification_section.touch
      flash[:notice] = "Successfully updated section document."
      redirect_to section_documents_path(:job_id => @job.id, :specification_section_id => @specification_section.id)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @section_document = SectionDocument.find(params[:id])
    inc(@section_document.specification_section_id)
    @job = @specification_section.specification.job
    @client = @job.client
    @section_document.destroy
    @specification_section.touch
    flash[:notice] = "Successfully destroyed section document."
    redirect_to section_documents_path(:job_id => @job.id, :specification_section_id => @specification_section.id)
  end
  
  def download
    @document = SectionDocument.find(params[:id])
    @ccf = CloudFiles::Connection.new(CLOUD_CONFIG['username'],CLOUD_CONFIG['api_key'])
    container = @ccf.container(CLOUD_CONFIG['container'])
    object = container.object(@document.doc.path)
    tmp = File.open(RAILS_ROOT + "/tmp/downloads/"+@document.doc_file_name, "w+")
    tmp.syswrite(object.data)
    #render :url => object.public_url
    #puts tmp.path
    send_file(tmp.path,
                :disposition => 'inline',
               :encoding => 'utf8', 
               :type => object.content_type,
               :filename => URI.encode(@document.doc_file_name))
    # send_file(@document.doc.path,:disposition => 'inline',
    #           :encoding => 'utf8', 
    #           :type => @document.doc_content_type,
    #           :filename => URI.encode(@document.doc_file_name))
  end
end
