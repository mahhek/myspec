class TemplateSpecificationSectionsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager, :except => [:destroy, :update, :create]
       allow logged_in
  end
  def index
    @template_template_specification_sections = TemplateSpecificationSection.all
  end
  
  def show
    @template_specification_section = TemplateSpecificationSection.find(params[:id])
  end
  
  def new
    @template_specification_section = TemplateSpecificationSection.new(:template_specification_id => params[:template_specification_id])
  end
  
  def create
    @template_specification_section = TemplateSpecificationSection.new(params[:template_specification_section])
    template_job = @template_specification_section.template_specification.job.id
    if @template_specification_section.save
      flash[:notice] = "Specification section successfully created."
      redirect_to template_job_path(template_job)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @template_specification_section = TemplateSpecificationSection.find(params[:id])
  end
  
  def update
    @template_specification_section = TemplateSpecificationSection.find(params[:id])
    if @template_specification_section.update_attributes(params[:template_specification_section])
      flash[:notice] = "Specification section successfully updated ."
      redirect_to @template_specification_section
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @template_specification_section = TemplateSpecificationSection.find(params[:id])
    template_job = @template_specification_section.template_specification.template_job
    @template_specification_section.destroy
    flash[:notice] = "Specification section successfully removed."
    redirect_to template_job_path(template_job)
  end
end
