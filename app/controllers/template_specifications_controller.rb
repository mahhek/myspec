class TemplateSpecificationsController < ApplicationController
  before_filter :login_required
  access_control do
       allow :admin
       allow :manager, :except => [:destroy, :update, :create]
       allow logged_in
  end
  def index
    @template_specification = TemplateSpecification.all
  end
  
  def show
    @template_specification = TemplateSpecification.find(params[:id])
  end
  
  def new
    @template_specification = TemplateSpecification.new(:job_id => params[:job_id])
  end
  
  def create
    @template_specification = TemplateSpecification.new(params[:template_specification])
    if @template_specification.save
      flash[:notice] = "Successfully created division."
      redirect_to job_path(@template_specification.job)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @template_specification = TemplateSpecification.find(params[:id])
  end
  
  def update
    @template_specification = TemplateSpecification.find(params[:id])
    if @template_specification.update_attributes(params[:template_specification])
      flash[:notice] = "Successfully updated division."
      redirect_to @template_specification
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @template_specification = TemplateSpecification.find(params[:id])
    template_job= @template_specification.template_job
    @template_specification.destroy
    flash[:notice] = "Successfully removed division."
    redirect_to template_job_path(template_job)
  end
end
