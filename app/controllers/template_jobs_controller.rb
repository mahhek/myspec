class TemplateJobsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager
       # allow :manager, :except => [:destroy, :update, :create]
       # allow logged_in
  end
  def index
    if current_user.parent_id.nil?
      @admins = User.id_or_parent_id_equals(current_user.id)
    else
      @admins = User.id_or_parent_id_equals(current_user.parent.id)
    end
    
    admin = Array.new
    x = 0 
    admin[0] = 0
    for c in @admins
      admin[x] = c.id
      x += 1
    end
 
    @template_jobs = TemplateJob.user_id_equals(admin)
    @template_job = TemplateJob.new(:job_id => params[:job_id])
  end
  
  def show
    @template_job = TemplateJob.find(params[:id], :include => [{:template_specifications => :template_specification_sections}], :order => "template_specifications.division_id ASC, template_specification_sections.section_id ASC")
    #@job = Job.find(params[:id], :include => [{:specifications => :specification_sections}], :order => "specifications.division_id ASC, specification_sections.section_id ASC")
    @template_specification = TemplateSpecification.new(:template_job_id => @template_job.id)
    @template_specification_section = SpecificationSection.new
    #@job = Job.find(@template_job.job_id)
    #@specification = Specification.new(:job_id => @job.id)
    #@specification_section = SpecificationSection.new
  end
  
  def add_multiple_divisions
    @template_job = TemplateJob.find(params[:template_job_id])
    @divisions = have_divisions(@template_job.id)
    @template_specification = TemplateSpecification.new(:template_job_id => params[:template_job_id])
  end
  
  def create_multiple_divisions
    divisions = have_divisions(params[:template_specification][:template_job_id])
    for division in divisions
      if params[:divisions][division.id.to_s][:id] == "1"
        TemplateSpecification.create(:template_job_id => params[:template_specification][:template_job_id], :division_id => division.id )
      end 
    end
    
    redirect_to template_job_path(params[:template_specification][:template_job_id])
  end
  
  def add_multiple_sections
    @template_specification = TemplateSpecification.find(params[:template_specification_id])
    @template_job =  @template_specification.template_job
    @sections = have_sections(@template_specification.id, @template_specification.division.search_number)
    @template_specification_section = TemplateSpecificationSection.new(:template_specification_id => params[:template_specification_id])
  end
  
  def create_multiple_sections
    template_specification = TemplateSpecification.find(params[:template_specification_section][:template_specification_id])
    sections = have_sections(params[:template_specification_section][:template_specification_id], template_specification.division.search_number)
    for section in sections
      if params[:sections][section.id.to_s][:id] == "1"
        TemplateSpecificationSection.create(:template_specification_id => params[:template_specification_section][:template_specification_id], :section_id => section.id)
      end 
    end
    
    redirect_to template_job_path(template_specification.template_job_id)
  end
  
  def have_divisions(job_id)
    specifications = TemplateSpecification.template_job_id_eq(job_id)
    x = 0
    divs = Array.new
    divs[x] = 0
    for spec in specifications
      divs[x] = spec.division_id
      x = x + 1
    end
    divisions = Division.id_does_not_equal(divs)
    return divisions
  end
  
  def have_sections(specification_id, division_number)
    sections = TemplateSpecificationSection.template_specification_id_eq(specification_id)
    x = 0
    secs = Array.new
    secs[x] = 0
    for section in sections
      secs[x] = section.section_id
      x = x + 1
    end
    sections = Section.id_does_not_equal(secs).number_begins_with(division_number).number_not_begin_with("#{division_number}00")
    return sections
  end
  
  def new
    @template_job = TemplateJob.new(:job_id => params[:job_id])
    @job = Job.find(params[:job_id])
    @client = @job.client
  end
  
  def create
    @template_job = TemplateJob.new(params[:template_job])
    @template_job.user_id = current_user.id
    if @template_job.save
      if @template_job.job_id != nil
        specifications = Specification.job_id_equals(@template_job.job_id)
        for specification in specifications
            #create new job specifications
            new_spec = TemplateSpecification.create(:template_job_id => @template_job.id, :division_id => specification.division_id)
            #get specification sections
            specification_sections = SpecificationSection.find(:all, :conditions => {:specification_id => specification.id})
            for specification_section in specification_sections
              #create new section
              new_specification_section = TemplateSpecificationSection.create(:template_specification_id => new_spec.id, :section_id => specification_section.section_id)
            end
        end
      end
      flash[:notice] = "Successfully created template job."
      redirect_to @template_job
      #redirect_to "/jobs/#{@template_job.job_id}"
    else
      if current_user.parent_id.nil?
        @admins = User.id_or_parent_id_equals(current_user.id)
      else
        @admins = User.id_or_parent_id_equals(current_user.parent.id)
      end

      admin = Array.new
      x = 0 
      admin[0] = 0
      for c in @admins
        admin[x] = c.id
        x += 1
      end

      @template_jobs = TemplateJob.user_id_equals(admin)
      if @template_job.job_id == nil
        render :action => 'index'
      else
        flash[:warning] = "Template name cannot be blank"
        redirect_to new_template_job_path(:job_id => @template_job.job_id)
      end
    end
  end
  
  def edit
    @template_job = TemplateJob.find(params[:id])
  end
  
  def update
    @template_job = TemplateJob.find(params[:id])
    if @template_job.update_attributes(params[:template_job])
      flash[:notice] = "Successfully updated template job."
      redirect_to @template_job
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @template_job = TemplateJob.find(params[:id])
    @template_job.destroy
    flash[:notice] = "Successfully destroyed template job."
    redirect_to template_jobs_url
  end
  
  def spec_sec
    @template_job = TemplateJob.find(params[:template_id])
    @parts = Part.find(:all)
    @specification_section = SpecificationSection.find(params[:specification_section_id])
    @list_general_articles = PartArticle.find(:all, :conditions => {:specification_section_id => @specification_section, :part_id => "1"})
    @list_product_articles = PartArticle.find(:all, :conditions => {:specification_section_id => @specification_section, :part_id => "2"})
    @list_execution_articles = PartArticle.find(:all, :conditions => {:specification_section_id => @specification_section, :part_id => "3"})
    @spec_sec_part = SpecSecPart.new(:specification_section_id => params[:specification_section_id])
  end
end
